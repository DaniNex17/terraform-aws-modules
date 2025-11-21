# Nombre del topic SNS
topic_name = "my-sns-topic"

# KMS Key para cifrado (opcional)
# Por defecto usa la clave administrada por AWS: alias/aws/sns
# Puedes especificar tu propia KMS key si tienes una personalizada
# kms_master_key = "alias/my-custom-kms-key"

# Tags personalizados
tags = {
  environment = "dev"
  project     = "personal"
  managed_by  = "terraform"
}

# Suscripciones al topic
subscriptions = [
  {
    protocol = "sqs"
    endpoint = "arn:aws:sqs:us-east-1:356272969745:my-personal-queue-complete"
  }
  # Otros ejemplos:
  # {
  #   protocol = "email"
  #   endpoint = "your-email@example.com"
  # },
  # {
  #   protocol = "https"
  #   endpoint = "https://example.com/webhook"
  # },
  # {
  #   protocol = "lambda"
  #   endpoint = "arn:aws:lambda:us-east-1:123456789012:function:my-function"
  # }
]

# Habilitar logs en CloudWatch
enable_cloudwatch_logs = false

# Tasa de muestreo para logs de éxito (0-100%)
sqs_success_feedback_rate = 45
