resource "aws_sns_topic" "main" {
  name              = var.name
  kms_master_key_id = data.aws_kms_key.main.id
  tags              = local.resource_tags

  sqs_success_feedback_sample_rate = var.enable_cloudwatch_logs ? var.sqs_success_feedback_rate : null
  sqs_success_feedback_role_arn    = var.enable_cloudwatch_logs ? aws_iam_role.sns_logs_role[0].arn : null
  sqs_failure_feedback_role_arn    = var.enable_cloudwatch_logs ? aws_iam_role.sns_logs_role[0].arn : null
}

resource "aws_sns_topic_subscription" "main" {
  count     = length(var.subscriptions)
  topic_arn = aws_sns_topic.main.arn
  protocol  = var.subscriptions[count.index].protocol
  endpoint  = var.subscriptions[count.index].endpoint
}

resource "aws_sns_topic_policy" "default" {
  count  = length(var.sns_policy) > 0 ? 1 : 0
  arn    = aws_sns_topic.main.arn
  policy = data.aws_iam_policy_document.policy.json
}
