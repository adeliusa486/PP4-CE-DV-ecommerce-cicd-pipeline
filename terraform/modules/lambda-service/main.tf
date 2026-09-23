# 1. The ID Badge (IAM Role) for our code
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-${var.environment}-${var.service_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# 2. Giving the ID badge specific permissions (Logs, Database, EventBridge, SQS)
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-${var.environment}-${var.service_name}-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query"
        ]
        Resource = length(var.dynamodb_table_arns) > 0 ? var.dynamodb_table_arns : ["arn:aws:dynamodb:*:*:table/dummy-table-do-not-use"]
      },
      {
        Effect = "Allow"
        Action = ["events:PutEvents"]
        Resource = var.event_bus_arn
      },
      {
        Effect = "Allow"
        Action = ["sqs:SendMessage"]
        Resource = var.dlq_arn
      }
    ]
  })
}

# 3. The actual Lambda Function
resource "aws_lambda_function" "this" {
  function_name    = "${var.project_name}-${var.environment}-${var.service_name}"
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  timeout          = 30
  memory_size      = 256
  role             = aws_iam_role.lambda_role.arn

  environment {
    variables = merge(var.environment_variables, {
      EVENT_BUS_NAME = var.event_bus_name
      ENVIRONMENT    = var.environment
      SERVICE_NAME   = var.service_name
    })
  }

  dead_letter_config {
    target_arn = var.dlq_arn
  }
}

# 4. The Log Folder
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 14
}

# 5. Allowing EventBridge to trigger this Lambda (only if needed)
resource "aws_lambda_permission" "eventbridge" {
  count         = var.create_eventbridge_permission ? 1 : 0
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.eventbridge_rule_arn
}

# 6. Linking the EventBridge rule to this Lambda (only if needed)
resource "aws_cloudwatch_event_target" "this" {
  count          = var.create_eventbridge_permission ? 1 : 0
  rule           = var.eventbridge_rule_name
  target_id      = var.service_name
  arn            = aws_lambda_function.this.arn
  event_bus_name = var.event_bus_name
}
