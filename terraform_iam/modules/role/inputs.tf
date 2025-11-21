variable "role_name" {
  description = "Name of the IAM role"
  type        = string
  nullable    = false
}

variable "assume_role_policy" {
  description = "JSON policy document for assume role policy"
  type        = string
  nullable    = false
}

variable "description" {
  description = "Description of the IAM role"
  type        = string
  default     = ""
}

variable "max_session_duration" {
  description = "Maximum session duration (in seconds) for the role"
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "Max session duration must be between 3600 and 43200 seconds."
  }
}

variable "path" {
  description = "Path for the IAM role"
  type        = string
  default     = "/"
}

variable "permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the role"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the IAM role"
  type        = map(string)
  default     = {}
}

# Políticas gestionadas de AWS (más simple)
variable "managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

# Políticas personalizadas (estilo empresa pero simplificado)
variable "role_policies" {
  description = "Map of custom policies to create and attach to the role"
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
  default = {}

  validation {
    condition     = alltrue([for policy, value in var.role_policies : length(value.statements) > 0])
    error_message = "Each policy must have at least one statement."
  }
}