# 1. Give the Manager an ID Badge (IAM Role)
resource "aws_iam_role" "sfn_role" {
  name = "${var.project_name}-${var.environment}-saga-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })
}

# 2. Give the Manager permission to command (invoke) our specific microservices
resource "aws_iam_role_policy" "sfn_policy" {
  name = "${var.project_name}-${var.environment}-saga-policy"
  role = aws_iam_role.sfn_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["lambda:InvokeFunction"]
        Resource = [
          var.payment_lambda_arn,
          var.inventory_lambda_arn,
          var.notification_lambda_arn
        ]
      }
    ]
  })
}

# 3. Create the actual Manager (Step Function State Machine)
resource "aws_sfn_state_machine" "saga_orchestrator" {
  name     = "${var.project_name}-${var.environment}-saga-orchestrator"
  role_arn = aws_iam_role.sfn_role.arn

  # We will put the flowchart rules in a separate JSON file and load it here
  definition = templatefile("${path.module}/saga_machine.asl.json", {
    PaymentLambdaArn      = var.payment_lambda_arn
    InventoryLambdaArn    = var.inventory_lambda_arn
    NotificationLambdaArn = var.notification_lambda_arn
  })
}