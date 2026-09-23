resource "aws_sqs_queue" "dlq" {
  name                       = "${var.project_name}-${var.environment}-${var.service_name}-dlq"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 300

  tags = {
    Name    = "${var.project_name}-${var.service_name}-dlq"
    Service = var.service_name
  }
}