output "event_bus_name" {
  value = aws_cloudwatch_event_bus.main.name
}

output "event_bus_arn" {
  value = aws_cloudwatch_event_bus.main.arn
}

output "order_created_rule_arn" {
  value = aws_cloudwatch_event_rule.order_created.arn
}

output "order_created_rule_name" {
  value = aws_cloudwatch_event_rule.order_created.name
}

# (The rest of the rule outputs follow the exact same pattern)
output "payment_succeeded_rule_arn" {
  value = aws_cloudwatch_event_rule.payment_succeeded.arn
}

output "payment_succeeded_rule_name" {
  value = aws_cloudwatch_event_rule.payment_succeeded.name
}

output "payment_failed_rule_arn" {
  value = aws_cloudwatch_event_rule.payment_failed.arn
}

output "payment_failed_rule_name" {
  value = aws_cloudwatch_event_rule.payment_failed.name
}

output "inventory_reserved_rule_arn" {
  value = aws_cloudwatch_event_rule.inventory_reserved.arn
}

output "inventory_reserved_rule_name" {
  value = aws_cloudwatch_event_rule.inventory_reserved.name
}

output "inventory_failed_rule_arn" {
  value = aws_cloudwatch_event_rule.inventory_failed.arn
}

output "inventory_failed_rule_name" {
  value = aws_cloudwatch_event_rule.inventory_failed.name
}

output "order_confirmed_rule_arn" {
  value = aws_cloudwatch_event_rule.order_confirmed.arn
}

output "order_confirmed_rule_name" {
  value = aws_cloudwatch_event_rule.order_confirmed.name
}

output "order_cancelled_rule_arn" {
  value = aws_cloudwatch_event_rule.order_cancelled.arn
}

output "order_cancelled_rule_name" {
  value = aws_cloudwatch_event_rule.order_cancelled.name
}