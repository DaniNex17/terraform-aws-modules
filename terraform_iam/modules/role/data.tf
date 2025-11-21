# Data sources para el módulo IAM Role

# Obtener información de la cuenta actual
data "aws_caller_identity" "current" {}

# Obtener región actual
data "aws_region" "current" {}

# Generar documentos de políticas desde la configuración
data "aws_iam_policy_document" "policies" {
  for_each = var.role_policies

  dynamic "statement" {
    for_each = each.value.statements
    content {
      sid       = statement.value.sid
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
    }
  }
}