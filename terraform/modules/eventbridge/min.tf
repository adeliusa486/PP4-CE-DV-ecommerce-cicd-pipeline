resource "aws_cloudwatch_event_bus" "main" {
  name = "${var.project_name}-${var.environment}-bus"
}

resource "aws_cloudwatch_event_rule" "order_created" {
  name           = "${var.project_name}-${var.environment}-order-created"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["ecommerce.order-service"]
    detail-type = ["OrderCreated"]
  })
}

resource "aws_cloudwatch_event_rule" "payment_succeeded" {
  name           = "${var.project_name}-${var.environment}-payment-succeeded"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["ecommerce.payment-service"]
    detail-type = ["PaymentSucceeded"]
  })
}

resource "aws_cloudwatch_event_rule" "payment_failed" {
  name           = "${var.project_name}-${var.environment}-payment-failed"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["ecommerce.payment-service"]
    detail-type = ["PaymentFailed"]
  })
}

resource "aws_cloudwatch_event_rule" "inventory_reserved" {
  name           = "${var.project_name}-${var.environment}-inventory-reserved"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["ecommerce.inventory-service"]
    detail-type = ["InventoryReserved"]
  })
}

resource "aws_cloudwatch_event_rule" "inventory_failed" {
  name           = "${var.project_name}-${var.environment}-inventory-failed"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["ecommerce.inventory-service"]
    detail-type = ["InventoryFailed"]
  })
}

resource "aws_cloudwatch_event_rule" "order_confirmed" {
  name           = "${var.project_name}-${var.environment}-order-confirmed"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["ecommerce.order-service"]
    detail-type = ["OrderConfirmed"]
  })
}

resource "aws_cloudwatch_event_rule" "order_cancelled" {
  name           = "${var.project_name}-${var.environment}-order-cancelled"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["ecommerce.order-service"]
    detail-type = ["OrderCancelled"]
  })
}