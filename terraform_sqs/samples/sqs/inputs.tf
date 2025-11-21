################################################################################# VARIABLES DE RECURSO
################################################################################

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "queue_name" {
  description = "Nombre base de la cola SQS"
  type        = string
  nullable    = false
}

variable "use_name_prefix" {
  description = "Determina si el nombre se utiliza como prefijo"
  type        = bool
  default     = false
}

variable "delay_seconds" {
  description = "El tiempo en segundos que se retrasará la entrega de todos los mensajes en la cola. Un número entero de 0 a 900 (15 minutos). El valor predeterminado es 0 segundos."
  type        = number
  default     = 0
}

variable "max_message_size" {
  description = "El límite de cuántos bytes puede contener un mensaje antes de que Amazon SQS lo rechace. Un número entero desde 1024 bytes (1 KiB) hasta 262144 bytes (256 KiB). El valor predeterminado es 262144 (256 KiB)."
  type        = number
  default     = 262144
}

variable "message_retention_seconds" {
  description = "La cantidad de segundos que Amazon SQS retiene un mensaje. Número entero que representa segundos, desde 60 (1 minuto) hasta 1209600 (14 días). El valor predeterminado es 345600 (4 días)."
  type        = number
  default     = 345600
}

variable "receive_wait_time_seconds" {
  description = "El tiempo durante el cual una llamada de ReceiveMessage esperará a que llegue un mensaje (long polling) antes de regresar. Un número entero de 0 a 20 (segundos). El valor predeterminado es 0."
  type        = number
  default     = 0
}

variable "visibility_timeout_seconds" {
  description = "El tiempo de espera de visibilidad de la cola. Un número entero de 0 a 43200 (12 horas). El valor predeterminado es 30."
  type        = number
  default     = 30
}

variable "fifo_queue" {
  description = "Habilita el modo FIFO. En caso de ser necesario, revise la documentación para consultar los valores de configuración parametrizables de este tipo de colas."
  type        = bool
  default     = false
}

variable "fifo_throughput_limit" {
  description = "El límite de la cuota de rendimiento de la cola FIFO."
  type        = string
  default     = "perQueue"
}

variable "content_based_deduplication" {
  description = "Habilita deduplicación basada en contenido para colas FIFO"
  type        = bool
  default     = false
}

variable "deduplication_scope" {
  description = "El alcance para la eliminación de contenido duplicado en colas FIFO"
  type        = string
  default     = "queue"
}

variable "kms_master_key_id" {
  description = "ID de la llave KMS para cifrar. Asegúrese de que la clave KMS exista antes del despliegue."
  type        = string
  default     = null
  nullable    = true
}

variable "kms_data_key_reuse_period_seconds" {
  description = "El período de tiempo, en segundos, durante el cual Amazon SQS puede reutilizar una clave de datos para cifrar o descifrar mensajes antes de volver a llamar a AWS KMS. Un número entero que representa segundos, entre 60 segundos (1 minuto) y 86.400 segundos (24 horas). El valor predeterminado es 300 (5 minutos)."
  type        = number
  default     = 300
}

variable "redrive_policy" {
  description = "Objeto que permite el envío de mensajes a un Dead Letter Queue. maxReceiveCount: es el número de veces que un consumidor puede recibir un mensaje de una cola de origen antes de pasarlo a un DLQ. deadLetterTargetArn: arn del Dead Letter Queue que se desea utilizar. Se debe habilitar únicamente si se desea que la cola redirija los mensajes fallidos a un DLQ."
  type = object({
    deadLetterTargetArn = string
    maxReceiveCount     = number
  })
  default  = null
  nullable = true
}

variable "arn_sqs_source_to_this_dlq" {
  description = "ARNs que identifican los orígenes de los mensajes de la cola en caso que esta cola tenga la función de DLQ. Se debe habilitar si se desea que la cola tenga la función de DLQ."
  type        = list(string)
  default     = null
  nullable    = true
}

variable "extra_permissions" {
  description = "Permisos adicionales de la SQS (para permitir quién puede escribir/leer en ella)"
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
  default  = []
  nullable = true
}

variable "tags" {
  description = "Tags adicionales para aplicar a los recursos creados"
  type        = map(string)
  default     = {}
  nullable    = true
}
