data "aws_iam_policy_document" "log_policies" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "log_policies" {
  count  = var.enable_cloudwatch_logs ? 1 : 0
  name   = "${var.name}-cloudwatch-logs-policy"
  policy = data.aws_iam_policy_document.log_policies[0].json
  tags   = local.resource_tags
}

resource "aws_iam_role_policy_attachment" "policies_attachment" {
  count      = var.enable_cloudwatch_logs ? 1 : 0
  role       = aws_iam_role.sns_logs_role[0].name
  policy_arn = aws_iam_policy.log_policies[0].arn
}

resource "aws_iam_role" "sns_logs_role" {
  count = var.enable_cloudwatch_logs ? 1 : 0
  name  = "${var.name}-cloudwatch-logs-role"
  tags  = local.resource_tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "sns.amazonaws.com"
      }
    }]
  })
}
