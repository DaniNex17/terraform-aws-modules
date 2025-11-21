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
# Ejemplo básico - Configuración mínima
# module "simple_sns" {
#   source = "../../modules/sns"

#   name          = var.topic_name
#   subscriptions = var.subscriptions

#   sns_policy = [{
#     actions   = ["SNS:Publish"]
#     effect    = "Allow"
#     resources = ["*"]
#     sid       = "AllowPublish"
#     principals = [{
#       type        = "AWS"
#       identifiers = [data.aws_caller_identity.current.account_id]
#     }]
#   }]

#   tags = var.tags
# }

#---------------------------CONFIGURACIÓN COMPLETA-----------------#
# Ejemplo completo - Con todas las opciones
module "sns" {
  source = "../../modules/sns"

  name           = "${var.topic_name}-complete"
  kms_master_key = var.kms_master_key
  subscriptions  = var.subscriptions

  # Habilitar logs en CloudWatch
  enable_cloudwatch_logs    = var.enable_cloudwatch_logs
  sqs_success_feedback_rate = var.sqs_success_feedback_rate

  # Política personalizada
  sns_policy = [{
    actions   = ["SNS:Publish"]
    effect    = "Allow"
    resources = ["*"]
    sid       = "AllowPublish"
    principals = [{
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }]
    condition = [{
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }]
  }]

  tags = merge(var.tags, {
    Example = "Complete"
  })
}
