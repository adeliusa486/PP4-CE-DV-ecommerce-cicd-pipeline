output "queue_url" {
  value = aws_sqs_queue.dlq.url
}

output "queue_arn" {
  value = aws_sqs_queue.dlq.arn
}

output "queue_name" {
  value = aws_sqs_queue.dlq.name
}