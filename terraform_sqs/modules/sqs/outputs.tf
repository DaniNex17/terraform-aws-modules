output "sqs_queue_name" {
  description = "Nombre de la cola SQS"
  value       = aws_sqs_queue.this.name
}

output "sqs_queue_arn" {
  description = "ARN de la cola SQS"
  value       = aws_sqs_queue.this.arn
}

output "sqs_queue_id" {
  description = "ID/URL de la cola SQS"
  value       = aws_sqs_queue.this.id
}

output "sqs_queue_url" {
  description = "URL de la cola SQS"
  value       = aws_sqs_queue.this.url
}
