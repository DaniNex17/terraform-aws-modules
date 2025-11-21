data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "sqs_policy" {
  # Denegar acceso sin cifrado en tránsito (SecureTransport)
  statement {
    effect    = "Deny"
    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.this.arn]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  # Permitir operaciones básicas desde la cuenta
  statement {
    effect = "Allow"
    actions = [
      "SQS:SendMessage",
      "SQS:ReceiveMessage"
    ]
    resources = [aws_sqs_queue.this.arn]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  # Permisos adicionales dinámicos
  dynamic "statement" {
    for_each = var.extra_permissions != null && length(var.extra_permissions) > 0 ? var.extra_permissions : []
    content {
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources

      dynamic "condition" {
        for_each = statement.value.condition
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }

      dynamic "principals" {
        for_each = statement.value.principals
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      sid = statement.value.sid != null ? statement.value.sid : null
    }
  }
}
