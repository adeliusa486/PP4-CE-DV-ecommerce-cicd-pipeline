# 1. Create the API Front Door (HTTP API)
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-${var.environment}-api"
  protocol_type = "HTTP"
}

# 2. Create an Environment Stage (e.g., /dev)
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# 3. Create the Connection (Integration) to our Order Service
resource "aws_apigatewayv2_integration" "order_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.order_service_arn
  payload_format_version = "2.0"
}

# 4. Create the Route (e.g., POST /orders)
resource "aws_apigatewayv2_route" "post_orders" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /orders"
  target    = "integrations/${aws_apigatewayv2_integration.order_integration.id}"
}

# 5. Give the Front Door permission to unlock the Order Service
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.order_service_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}