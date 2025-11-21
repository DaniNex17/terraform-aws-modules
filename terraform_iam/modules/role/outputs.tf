output "role_arn" {
  description = "ARN del rol creado"
  value       = aws_iam_role.main_role.arn
}

output "role_name" {
  description = "Nombre del rol creado"
  value       = aws_iam_role.main_role.name
}

output "role_policy_arn" {
  description = "ARNs de las políticas personalizadas creadas"
  value       = values(aws_iam_policy.policy)[*].arn
}

output "role_policy_name" {
  description = "Nombres de las políticas personalizadas creadas"
  value       = values(aws_iam_policy.policy)[*].name
}
