resource "aws_dynamodb_table" "orders" {
  name         = "${var.project_name}-${var.environment}-orders"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "order_id"

  attribute {
    name = "order_id"
    type = "S"
  }

  attribute {
    name = "customer_id"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  global_secondary_index {
    name            = "CustomerIndex"
    hash_key        = "customer_id"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "StatusIndex"
    hash_key        = "status"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name = "${var.project_name}-orders"
  }
}

resource "aws_dynamodb_table" "payments" {
  name         = "${var.project_name}-${var.environment}-payments"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "payment_id"

  attribute {
    name = "payment_id"
    type = "S"
  }

  attribute {
    name = "order_id"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  global_secondary_index {
    name            = "OrderIndex"
    hash_key        = "order_id"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "PaymentStatusIndex"
    hash_key        = "status"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name = "${var.project_name}-payments"
  }
}

resource "aws_dynamodb_table" "products" {
  name         = "${var.project_name}-${var.environment}-products"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "product_id"

  attribute {
    name = "product_id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name = "${var.project_name}-products"
  }
}