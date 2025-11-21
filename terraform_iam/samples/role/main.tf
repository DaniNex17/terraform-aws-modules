################################################################################
# PROVIDER CONFIGURATION
################################################################################

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

################################################################################
# EJEMPLO DE USO
################################################################################

# Tenga en cuenta que los ejemplos de los módulos representan escenarios comunes 
# con configuraciones genéricas. Si necesita algo más específico, dentro del módulo 
# encontrará una serie de variables que le permitirán personalizar la solución 
# según su caso de uso.

module "role" {
  source = "../../modules/role"

  role_name          = var.role_name
  description        = var.role_description
  assume_role_policy = var.assume_role_policy

  # Políticas gestionadas de AWS
  managed_policy_arns = var.managed_policy_arns

  # Políticas personalizadas
  role_policies = var.role_policies

  # Configuración adicional
  max_session_duration = var.max_session_duration
  path                 = var.path
  permissions_boundary = var.permissions_boundary

  tags = var.tags
}
