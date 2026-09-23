variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "project_name" {
  type    = string
  default = "PP3-CE-event-driven-ecommerce"
}
variable "alert_email" {
  type        = string
  description = "The email address that will receive alerts when the system breaks"
}
