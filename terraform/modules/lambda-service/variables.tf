variable "project_name" { type = string }
variable "environment" { type = string }
variable "service_name" { type = string }
variable "lambda_zip_path" { type = string }
variable "dynamodb_table_arns" { type = list(string) }
variable "event_bus_arn" { type = string }
variable "event_bus_name" { type = string }
variable "dlq_arn" { type = string }
variable "environment_variables" {
  type    = map(string)
  default = {}
}
variable "create_eventbridge_permission" {
  type    = bool
  default = false
}
variable "eventbridge_rule_arn" {
  type    = string
  default = ""
}
variable "eventbridge_rule_name" {
  type    = string
  default = ""
}