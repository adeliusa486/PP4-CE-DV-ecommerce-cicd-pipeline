# 1. Create the Pager System (SNS Topic)
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"
}

# 2. Subscribe your email address to the Pager System
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# 3. Create the Security Guards (CloudWatch Alarms) for the Holding Pens
resource "aws_cloudwatch_metric_alarm" "dlq_alarms" {
  # This is a Terraform superpower! Instead of copy/pasting this code 4 times 
  # for our 4 queues, "for_each" automatically generates an alarm for every queue in our list.
  for_each = toset(var.dlq_names)

  alarm_name          = "${each.value}-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm if any messages land in the Dead Letter Queue"
  
  # If the alarm goes off, send a message to the Pager System (SNS)
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    QueueName = each.value
  }
}

# 4. Create the Control Room (CloudWatch Dashboard)
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 24
        height = 6
        properties = {
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Microservice Errors"
          metrics = [
            [ "AWS/Lambda", "Errors", "FunctionName", "${var.project_name}-${var.environment}-order-service" ],
            [ ".", ".", ".", "${var.project_name}-${var.environment}-payment-service" ],
            [ ".", ".", ".", "${var.project_name}-${var.environment}-inventory-service" ]
          ]
        }
      }
    ]
  })
}