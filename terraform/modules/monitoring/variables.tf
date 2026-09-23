variable "project_name" { type = string }
variable "environment" { type = string }
variable "aws_region" { type = string }
variable "alert_email" { type = string }

# We expect a list of holding pen names
variable "dlq_names" { type = list(string) }