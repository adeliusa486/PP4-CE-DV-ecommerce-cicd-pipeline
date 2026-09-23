terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = var.project_name
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}

# 1. Plug in the Message Hub
module "eventbridge" {
  source       = "../../modules/eventbridge"
  project_name = var.project_name
  environment  = var.environment
}

# 2. Plug in the Databases
module "dynamodb" {
  source       = "../../modules/dynamodb"
  project_name = var.project_name
  environment  = var.environment
}

# 3. Plug in the Safety Nets (Holding Pens)
module "order_dlq" {
  source       = "../../modules/sqs-dlq"
  project_name = var.project_name
  environment  = var.environment
  service_name = "order-service"
}

module "payment_dlq" {
  source       = "../../modules/sqs-dlq"
  project_name = var.project_name
  environment  = var.environment
  service_name = "payment-service"
}

# 4. Plug in the Order Service
module "order_service" {
  source              = "../../modules/lambda-service"
  project_name        = var.project_name
  environment         = var.environment
  service_name        = "order-service"
  lambda_zip_path     = "${path.module}/../../../services/order-service/order-service.zip"
  dynamodb_table_arns = [module.dynamodb.orders_table_arn]
  event_bus_arn       = module.eventbridge.event_bus_arn
  event_bus_name      = module.eventbridge.event_bus_name
  dlq_arn             = module.order_dlq.queue_arn

  environment_variables = {
    ORDERS_TABLE_NAME = module.dynamodb.orders_table_name
  }

  # Order service is triggered by web traffic, not by EventBridge messages
  create_eventbridge_permission = false
}

# 5. Plug in the Payment Service
module "payment_service" {
  source              = "../../modules/lambda-service"
  project_name        = var.project_name
  environment         = var.environment
  service_name        = "payment-service"
  lambda_zip_path     = "${path.module}/../../../services/payment-service/payment-service.zip"
  dynamodb_table_arns = [module.dynamodb.payments_table_arn]
  event_bus_arn       = module.eventbridge.event_bus_arn
  event_bus_name      = module.eventbridge.event_bus_name
  dlq_arn             = module.payment_dlq.queue_arn

  environment_variables = {
    PAYMENTS_TABLE_NAME = module.dynamodb.payments_table_name
  }

  # Payment service IS triggered by EventBridge (when an order is created)
  create_eventbridge_permission = false
}
# ---------------------------------------------------------
# NEW ADDITIONS FOR STEP 3
# ---------------------------------------------------------

# 6. Plug in the Front Door (API Gateway)
module "api_gateway" {
  source             = "../../modules/api-gateway"
  project_name       = var.project_name
  environment        = var.environment
  order_service_arn  = module.order_service.invoke_arn
  order_service_name = module.order_service.function_name
}

# 7. Plug in the Safety Nets (Holding Pens) for the new services
module "inventory_dlq" {
  source       = "../../modules/sqs-dlq"
  project_name = var.project_name
  environment  = var.environment
  service_name = "inventory-service"
}

module "notification_dlq" {
  source       = "../../modules/sqs-dlq"
  project_name = var.project_name
  environment  = var.environment
  service_name = "notification-service"
}

# 8. Plug in the Inventory Service
module "inventory_service" {
  source              = "../../modules/lambda-service"
  project_name        = var.project_name
  environment         = var.environment
  service_name        = "inventory-service"
  lambda_zip_path     = "${path.module}/../../../services/inventory-service/inventory-service.zip"
  dynamodb_table_arns = [module.dynamodb.products_table_arn]
  event_bus_arn       = module.eventbridge.event_bus_arn
  event_bus_name      = module.eventbridge.event_bus_name
  dlq_arn             = module.inventory_dlq.queue_arn

  # Triggered by EventBridge (OrderCreated)
  create_eventbridge_permission = false
  
}

# 9. Plug in the Notification Service
module "notification_service" {
  source              = "../../modules/lambda-service"
  project_name        = var.project_name
  environment         = var.environment
  service_name        = "notification-service"
  lambda_zip_path     = "${path.module}/../../../services/notification-service/notification-service.zip"
  dynamodb_table_arns = [] # No database needed for this service
  event_bus_arn       = module.eventbridge.event_bus_arn
  event_bus_name      = module.eventbridge.event_bus_name
  dlq_arn             = module.notification_dlq.queue_arn

  # We will temporarily trigger this on OrderConfirmed/Cancelled. 
  # In Step 4, our SAGA manager will handle sending these confirmed/cancelled events!
  create_eventbridge_permission = false
  
}

# 10. Print the Public URL to the console when Terraform finishes
output "public_api_url" {
  value       = "${module.api_gateway.api_url}orders"
  description = "The URL to send POST requests to create new orders"
}
# ---------------------------------------------------------
# NEW ADDITIONS FOR STEP 4
# ---------------------------------------------------------

# 11. Plug in the SAGA Manager (Step Functions)
module "saga_orchestrator" {
  source                  = "../../modules/step-functions"
  project_name            = var.project_name
  environment             = var.environment
  payment_lambda_arn      = module.payment_service.function_arn
  inventory_lambda_arn    = module.inventory_service.function_arn
  notification_lambda_arn = module.notification_service.function_arn
}

# 12. Tell EventBridge to trigger the Manager when a new order is created
resource "aws_cloudwatch_event_target" "trigger_saga" {
  rule           = module.eventbridge.order_created_rule_name
  target_id      = "SagaOrchestrator"
  arn            = module.saga_orchestrator.state_machine_arn
  event_bus_name = module.eventbridge.event_bus_name
  role_arn       = aws_iam_role.eventbridge_to_stepfunctions.arn
}

# 13. Give EventBridge the ID badge to trigger the Manager
resource "aws_iam_role" "eventbridge_to_stepfunctions" {
  name = "${var.project_name}-${var.environment}-eb-to-sfn-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "eventbridge_to_stepfunctions_policy" {
  name = "${var.project_name}-${var.environment}-eb-to-sfn-policy"
  role = aws_iam_role.eventbridge_to_stepfunctions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["states:StartExecution"]
        Resource = [module.saga_orchestrator.state_machine_arn]
      }
    ]
  })
}
# ---------------------------------------------------------
# NEW ADDITIONS FOR STEP 5
# ---------------------------------------------------------

# 14. Plug in the Security Guards & Pager System (Monitoring)
module "monitoring" {
  source       = "../../modules/monitoring"
  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
  alert_email  = var.alert_email

  # We hand the module a list of every Holding Pen name we want it to watch
  dlq_names = [
    module.order_dlq.queue_name,
    module.payment_dlq.queue_name,
    module.inventory_dlq.queue_name,
    module.notification_dlq.queue_name
  ]
}
