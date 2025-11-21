################################################################################
# CONFIGURACIÓN BÁSICA
################################################################################

variable "aws_region" {
  description = "Región de AWS donde se desplegará el recurso."
  type        = string
  default     = "us-east-1"
}

################################################################################
# VARIABLES DEL ROL
################################################################################

variable "role_name" {
  description = "Nombre completo del rol que se creará."
  type        = string
  nullable    = false
}

variable "role_description" {
  description = "Descripción del rol que se creará."
  type        = string
  default     = null
}

variable "assume_role_policy" {
  description = "Política de asunción del rol en formato JSON. Define quién puede asumir este rol."
  type        = string
  nullable    = false
}

variable "managed_policy_arns" {
  description = "Lista de ARNs de políticas gestionadas de AWS que se adjuntarán al rol."
  type        = list(string)
  default     = []
  nullable    = true
}

variable "role_policies" {
  description = "Mapa de políticas personalizadas para el rol. Define los permisos específicos del rol."
  type = map(object({
    policy_description = string
    statements = list(object({
      sid       = optional(string, null)
      effect    = string
      actions   = list(string)
      resources = list(string)
      condition = optional(list(object({
        test     = string
        variable = string
        values   = list(string)
      })), [])
    }))
  }))
  default  = {}
  nullable = true
}

variable "max_session_duration" {
  description = "Duración máxima de sesión en segundos (3600-43200)."
  type        = number
  default     = 3600
  nullable    = true
}

variable "path" {
  description = "Path del rol IAM."
  type        = string
  default     = "/"
  nullable    = true
}

variable "permissions_boundary" {
  description = "ARN del permissions boundary para limitar los permisos máximos del rol."
  type        = string
  default     = null
  nullable    = true
}

################################################################################
# TAGS
################################################################################

variable "tags" {
  description = "Tags adicionales para aplicar a los recursos creados."
  type        = map(string)
  default     = {}
  nullable    = true
}
