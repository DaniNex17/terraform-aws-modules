output "arn" {
  value       = aws_sns_topic.main.arn
  description = "ARN del topic SNS"
}
