################################################################################
# VARIABLES RECURSOS
################################################################################

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "topic_name" {
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
}
