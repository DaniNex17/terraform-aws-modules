################################################################################
# VARIABLES RECURSOS
################################################################################

variable "name" {
  description = "Nombre del topic SNS"
  type        = string
  nullable    = false
}

variable "kms_master_key" {
  description = "KMS para cifrar el topic SNS, puede enviar el ARN, ID o ALIAS de KMS"
  type        = string
  default     = "alias/aws/sns"
  nullable    = false
}

variable "tags" {
  description = "Tags adicionales para aplicar a los recursos creados"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "subscriptions" {
  description = "Listado de suscripciones al topic"
  type = list(object({
    protocol = string
    endpoint = string
  }))
  default  = []
  nullable = false
}

variable "sns_policy" {
  description = "Políticas personalizadas para el topic SNS"
  type = list(object({
    actions   = list(string)
    resources = list(string)
    effect    = string
    sid       = optional(string, null)
    principals = list(object({
      type        = string
      identifiers = list(string)
    }))
    condition = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for statement in var.sns_policy :
      alltrue([
        for principal in statement.principals :
        contains(principal.identifiers, "*") ? length(statement.condition) > 0 : true
      ])
    ])
    error_message = "Si un principal contiene '*', la política debe incluir al menos una condición."
  }
}

variable "enable_cloudwatch_logs" {
  description = "Habilitar logs de SNS en CloudWatch"
  type        = bool
  default     = false
  nullable    = false
}

variable "sqs_success_feedback_rate" {
  description = "Tasa de muestra de éxito para logs SQS (0-100%)"
  type        = number
  default     = 45
  nullable    = false

  validation {
    condition     = var.sqs_success_feedback_rate >= 0 && var.sqs_success_feedback_rate <= 100
    error_message = "La tasa debe estar entre 0 y 100."
  }
}
