################################################################################
# OUTPUTS
################################################################################

output "role_arn" {
  description = "ARN del rol creado"
  value       = module.role.role_arn
}

output "role_name" {
  description = "Nombre del rol creado"
  value       = module.role.role_name
}

output "role_policy_arns" {
  description = "ARNs de las políticas personalizadas creadas"
  value       = module.role.role_policy_arn
}

output "role_policy_names" {
  description = "Nombres de las políticas personalizadas creadas"
  value       = module.role.role_policy_name
}
