################################################################################
# VARIABLES DE RECURSOS
################################################################################

aws_region   = "us-east-1"

# Nombre base de la cola SQS
queue_name = "my-personal-queue"

# Determina si el nombre se utiliza como prefijo
use_name_prefix = false

# El tiempo en segundos que se retrasará la entrega de todos los mensajes en la cola.
# Un número entero de 0 a 900 (15 minutos). El valor predeterminado es 0 segundos.
delay_seconds = 90

# El límite de cuántos bytes puede contener un mensaje antes de que Amazon SQS lo rechace.
# Un número entero desde 1024 bytes (1 KiB) hasta 262144 bytes (256 KiB).
# El valor predeterminado es 262144 (256 KiB).
max_message_size = 2048

# La cantidad de segundos que Amazon SQS retiene un mensaje.
# Número entero que representa segundos, desde 60 (1 minuto) hasta 1209600 (14 días).
# El valor predeterminado es 345600 (4 días).
message_retention_seconds = 86400

# El tiempo durante el cual una llamada de ReceiveMessage esperará a que llegue un mensaje
# (long polling) antes de regresar. Un número entero de 0 a 20 (segundos).
# El valor predeterminado es 0, lo que significa que la llamada volverá inmediatamente.
receive_wait_time_seconds = 10

# El tiempo de espera de visibilidad de la cola.
# Un número entero de 0 a 43200 (12 horas). El valor predeterminado es 30.
visibility_timeout_seconds = 30

################################################################################
# CONFIGURACIÓN FIFO
################################################################################

# Habilita el modo FIFO
# IMPORTANTE: Si cambia de estándar a FIFO o viceversa, la cola será recreada
fifo_queue = false

# El límite de la cuota de rendimiento de la cola FIFO
# Valores permitidos: "perQueue" o "perMessageGroupId"
fifo_throughput_limit = "perQueue"

# Habilita deduplicación basada en contenido para colas FIFO
content_based_deduplication = false

# El alcance para la eliminación de contenido duplicado
# Valores permitidos: "queue" o "messageGroup"
deduplication_scope = "queue"

################################################################################
# CIFRADO KMS
################################################################################

# ID de la llave KMS para cifrar
# Asegúrese de que la clave KMS exista antes del despliegue
# Puede ser un ARN completo, un ID de key, o un alias como "alias/aws/sqs"
# Si se deja en null, SQS usará cifrado por defecto de AWS (SSE-SQS)
kms_master_key_id = null
# kms_master_key_id = "6d1e40b3-4edb-4f2d-b463-5617589f1d0e"  # Ejemplo de KMS key ID
# kms_master_key_id = "alias/aws/sqs"  # Ejemplo usando alias de AWS
# kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"  # Ejemplo de ARN completo

# El período de tiempo, en segundos, durante el cual Amazon SQS puede reutilizar
# una clave de datos para cifrar o descifrar mensajes antes de volver a llamar a AWS KMS.
# Un número entero que representa segundos, entre 60 (1 minuto) y 86.400 (24 horas).
# El valor predeterminado es 300 (5 minutos).
# NOTA: Solo aplica si kms_master_key_id está definido
kms_data_key_reuse_period_seconds = 300

################################################################################
# DEAD LETTER QUEUE (DLQ)
################################################################################

# Configuración de Dead Letter Queue
# Habilitar solo si desea redirigir mensajes fallidos a un DLQ
# maxReceiveCount: número de veces que un consumidor puede recibir un mensaje
#                  antes de pasarlo a un DLQ
# deadLetterTargetArn: ARN del Dead Letter Queue que se desea utilizar
redrive_policy = null
# redrive_policy = {
#   deadLetterTargetArn = "arn:aws:sqs:us-east-1:123456789012:my-dlq"
#   maxReceiveCount     = 5
# }

# ARNs que identifican los orígenes de los mensajes si esta cola funciona como DLQ
# Habilitar solo si esta cola recibe mensajes de otras colas
arn_sqs_source_to_this_dlq = null
# arn_sqs_source_to_this_dlq = [
#   "arn:aws:sqs:us-east-1:123456789012:source-queue-1",
#   "arn:aws:sqs:us-east-1:123456789012:source-queue-2"
# ]

################################################################################
# PERMISOS ADICIONALES
################################################################################

# Permisos adicionales de la SQS (para permitir quién puede escribir/leer en ella)
# Por defecto, solo la cuenta actual tiene permisos (definido en el módulo)

# Permitir a SNS enviar mensajes a esta cola
extra_permissions = [
  {
    principals = [
      {
        type        = "Service"
        identifiers = ["sns.amazonaws.com"]
      }
    ]
    actions   = ["SQS:SendMessage"]
    effect    = "Allow"
    resources = ["*"]
    sid       = "AllowSNSSendMessage"
    condition = [
      {
        test     = "ArnEquals"
        variable = "aws:SourceArn"
        values   = ["arn:aws:sns:us-east-1:356272969745:my-sns-topic-complete"]
      }
    ]
  }
]

# Ejemplo adicional: Permitir a Lambda enviar mensajes
# extra_permissions = [
#   {
#     principals = [
#       {
#         type        = "Service"
#         identifiers = ["lambda.amazonaws.com"]
#       }
#     ]
#     actions   = ["SQS:SendMessage"]
#     effect    = "Allow"
#     resources = ["*"]
#     sid       = "AllowLambdaSendMessage"
#     condition = [
#       {
#         test     = "ArnEquals"
#         variable = "aws:SourceArn"
#         values   = ["arn:aws:lambda:us-east-1:356272969745:function:my-function"]
#       }
#     ]
#   }
# ]

# Ejemplo adicional: Permitir a una cuenta específica enviar mensajes
# extra_permissions = [
#   {
#     principals = [
#       {
#         type        = "AWS"
#         identifiers = ["arn:aws:iam::123456789012:root"]
#       }
#     ]
#     actions   = ["SQS:SendMessage"]
#     effect    = "Allow"
#     resources = ["*"]
#     sid       = "AllowExternalAccountSendMessage"
#     condition = []
#   }
# ]

################################################################################
# TAGS
################################################################################

# Tags adicionales para aplicar a los recursos creados
tags = {
  environment = "dev"
  project     = "personal"
  managed_by  = "terraform"
  owner       = "daniel"
}
