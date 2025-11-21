# Los ejemplos de los módulos representan escenarios comunes con configuraciones genéricas.
# Si necesita algo más específico, dentro del módulo encontrará variables que le permitirán
# personalizar la solución según su caso de uso.

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

#---------------------------ARGUMENTOS MÍNIMOS-----------------#
# Cola SQS simple con configuración básica
# module "simple_sqs" {
#   source = "../../modules/sqs"

#   queue_name                = var.queue_name
#   delay_seconds             = var.delay_seconds
#   max_message_size          = var.max_message_size
#   message_retention_seconds = var.message_retention_seconds
#   receive_wait_time_seconds = var.receive_wait_time_seconds

#   tags = var.tags
# }

#---------------------------CONFIGURACIÓN COMPLETA-----------------#
# Cola SQS con todas las opciones configuradas
module "complete_sqs" {
  source = "../../modules/sqs"

  queue_name      = "${var.queue_name}-complete"
  use_name_prefix = var.use_name_prefix

  # Configuración de mensajes
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  # Cifrado KMS (asegúrese de que la clave KMS exista antes del despliegue)
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds

  # Dead Letter Queue (habilitar solo si desea redirigir mensajes fallidos a un DLQ)
  redrive_policy = var.redrive_policy

  # Si esta cola funciona como DLQ (habilitar solo si esta cola recibe mensajes de otras colas)
  arn_sqs_source_to_this_dlq = var.arn_sqs_source_to_this_dlq

  # Permisos adicionales (para permitir acceso desde otros servicios)
  extra_permissions = var.extra_permissions

  tags = var.tags
}

#---------------------------COLA FIFO-----------------#
# IMPORTANTE: Si inicialmente creó una cola estándar y ahora desea convertirla en FIFO,
# se llevará a cabo un proceso de reconstrucción (eliminación y recreación).
# Lo mismo aplica si cambia de FIFO a estándar.
# module "fifo_sqs" {
#   source = "../../modules/sqs"

#   queue_name = "${var.queue_name}-fifo"

#   # Configuración básica
#   delay_seconds              = var.delay_seconds
#   max_message_size           = var.max_message_size
#   message_retention_seconds  = var.message_retention_seconds
#   receive_wait_time_seconds  = var.receive_wait_time_seconds
#   visibility_timeout_seconds = var.visibility_timeout_seconds

#   # Configuración FIFO
#   fifo_queue                  = var.fifo_queue
#   fifo_throughput_limit       = var.fifo_throughput_limit
#   content_based_deduplication = var.content_based_deduplication
#   deduplication_scope         = var.deduplication_scope

#   # Cifrado KMS
#   kms_master_key_id                 = var.kms_master_key_id
#   kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds

#   # Permisos adicionales
#   extra_permissions = var.extra_permissions

#   tags = var.tags
# }


