variable "queue_name" {
  description = "Nombre de la cola SQS"
  type        = string
  nullable    = false
}

variable "use_name_prefix" {
  description = "Determina si el nombre se utiliza como prefijo"
  type        = bool
  default     = false
}

variable "delay_seconds" {
  description = "Tiempo de retraso para entregar mensajes (0-900 segundos)"
  type        = number
  default     = 0
  validation {
    condition     = var.delay_seconds >= 0 && var.delay_seconds <= 900
    error_message = "delay_seconds debe estar entre 0 y 900 segundos."
  }
}

variable "max_message_size" {
  description = "Tamaño máximo del mensaje en bytes (1024-262144)"
  type        = number
  default     = 262144
  validation {
    condition     = var.max_message_size >= 1024 && var.max_message_size <= 262144
    error_message = "max_message_size debe estar entre 1024 y 262144 bytes."
  }
}

variable "message_retention_seconds" {
  description = "Tiempo de retención de mensajes en segundos (60-1209600)"
  type        = number
  default     = 345600 # 4 días
  validation {
    condition     = var.message_retention_seconds >= 60 && var.message_retention_seconds <= 1209600
    error_message = "message_retention_seconds debe estar entre 60 y 1209600 segundos."
  }
}

variable "receive_wait_time_seconds" {
  description = "Tiempo de espera para long polling (0-20 segundos)"
  type        = number
  default     = 0
  validation {
    condition     = var.receive_wait_time_seconds >= 0 && var.receive_wait_time_seconds <= 20
    error_message = "receive_wait_time_seconds debe estar entre 0 y 20 segundos."
  }
}

variable "visibility_timeout_seconds" {
  description = "Tiempo de timeout de visibilidad en segundos (0-43200)"
  type        = number
  default     = 30
  validation {
    condition     = var.visibility_timeout_seconds >= 0 && var.visibility_timeout_seconds <= 43200
    error_message = "visibility_timeout_seconds debe estar entre 0 y 43200 segundos (12 horas)."
  }
}

variable "fifo_queue" {
  description = "Si la cola es FIFO (debe terminar en .fifo)"
  type        = bool
  default     = false
}

variable "fifo_throughput_limit" {
  description = "El límite de la cuota de rendimiento de la cola FIFO"
  type        = string
  default     = "perQueue"
  nullable    = false
  validation {
    condition     = contains(["perQueue", "perMessageGroupId"], var.fifo_throughput_limit)
    error_message = "fifo_throughput_limit debe ser 'perQueue' o 'perMessageGroupId'."
  }
}

variable "content_based_deduplication" {
  description = "Habilita deduplicación basada en contenido para colas FIFO"
  type        = bool
  default     = false
}

variable "deduplication_scope" {
  description = "El alcance para la eliminación de contenido duplicado"
  type        = string
  default     = "queue"
  nullable    = false
  validation {
    condition     = contains(["messageGroup", "queue"], var.deduplication_scope)
    error_message = "deduplication_scope debe ser 'messageGroup' o 'queue'."
  }
}

variable "kms_master_key_id" {
  description = "ID de la KMS key para cifrado (opcional)"
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  description = "Período de reutilización de la data key de KMS (60-86400 segundos)"
  type        = number
  default     = 300
  nullable    = false
  validation {
    condition     = var.kms_data_key_reuse_period_seconds >= 60 && var.kms_data_key_reuse_period_seconds <= 86400
    error_message = "kms_data_key_reuse_period_seconds debe estar entre 60 y 86400 segundos (1 minuto a 24 horas)."
  }
}

variable "redrive_policy" {
  description = "Objeto que permite el envío de mensajes a un Dead Letter Queue"
  type = object({
    deadLetterTargetArn = string
    maxReceiveCount     = number
  })
  default  = null
  nullable = true
}

variable "arn_sqs_source_to_this_dlq" {
  description = "ARNs que identifican los orígenes de los mensajes si esta cola funciona como DLQ"
  type        = list(string)
  default     = null
  nullable    = true
}

variable "extra_permissions" {
  description = "Permisos adicionales para la cola SQS (para permitir quién puede escribir/leer)"
  type = list(object({
    actions   = list(string)
    resources = list(string)
    effect    = string
    sid       = optional(string)
    principals = list(object({
      type        = optional(string, "AWS")
      identifiers = list(string)
    }))
    condition = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
  nullable = true
  default  = []
  validation {
    condition     = alltrue([for statement in var.extra_permissions : length(statement.principals) > 0])
    error_message = "Cada statement debe definir al menos un principal."
  }
}

variable "tags" {
  description = "Tags para aplicar a la cola"
  type        = map(string)
  default     = {}
}
