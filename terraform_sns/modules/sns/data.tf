data "aws_kms_key" "main" {
  key_id = var.kms_master_key
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "policy" {
  dynamic "statement" {
    for_each = var.sns_policy
    content {
      actions   = statement.value.actions
      effect    = statement.value.effect
      resources = statement.value.resources
      sid       = statement.value.sid

      dynamic "condition" {
        for_each = statement.value.condition
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }

      condition {
        test     = "Bool"
        variable = "aws:SecureTransport"
        values   = ["true"]
      }

      dynamic "principals" {
        for_each = statement.value.principals
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }
    }
  }
}
