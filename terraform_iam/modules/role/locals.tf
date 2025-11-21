locals {
  # Tags comunes que se aplicarán a todos los recursos
  resource_tags = merge(
    {
      managed_by = "terraform"
      module     = "iam-role"
    },
    var.tags
  )

  # Información de la cuenta
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.id

  # Validaciones
  has_custom_policies  = length(var.role_policies) > 0
  has_managed_policies = length(var.managed_policy_arns) > 0
  has_any_policies     = local.has_custom_policies || local.has_managed_policies
}