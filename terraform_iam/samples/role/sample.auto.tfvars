################################################################################
# CONFIGURACIÓN BÁSICA
################################################################################

# Región de AWS donde se desplegará el recurso
aws_region = "us-east-1"

################################################################################
# CONFIGURACIÓN DEL ROL
################################################################################

# Nombre completo del rol que se creará
role_name = "my-role-dev"

# Descripción del rol que se creará
role_description = "Rol para ejecutar funciones Lambda con acceso a S3 y DynamoDB"

################################################################################
# POLÍTICA DE ASUNCIÓN (OBLIGATORIO)
# Define QUIÉN puede asumir este rol
################################################################################

# Ejemplo para Lambda
assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF

# Otros ejemplos de políticas de asunción:
#
# Para API Gateway:
# assume_role_policy = <<-EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "apigateway.amazonaws.com"
#       }
#     }
#   ]
# }
# EOF
#
# Para EC2:
# assume_role_policy = <<-EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       }
#     }
#   ]
# }
# EOF

################################################################################
# POLÍTICAS GESTIONADAS DE AWS (OPCIONAL)
# Políticas predefinidas por AWS que se adjuntarán al rol
# Deja vacío [] si no necesitas políticas gestionadas
################################################################################

managed_policy_arns = [
  "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
]

# Otros ejemplos de políticas gestionadas comunes:
# "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
# "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
# "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
# "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"

################################################################################
# POLÍTICAS PERSONALIZADAS (OPCIONAL)
# Define permisos específicos para el rol
# Deja vacío {} si no necesitas políticas personalizadas
################################################################################

role_policies = {
  # Política para acceso a S3
  s3_access = {
    policy_description = "Permisos de lectura y escritura en S3"
    statements = [
      {
        sid    = "S3ReadWrite"
        effect = "Allow"
        actions = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        resources = [
          "arn:aws:s3:::my-bucket/*"
        ]
      },
      {
        sid    = "S3ListBucket"
        effect = "Allow"
        actions = [
          "s3:ListBucket"
        ]
        resources = [
          "arn:aws:s3:::my-bucket"
        ]
      }
    ]
  }

  # Política para acceso a DynamoDB
  dynamodb_access = {
    policy_description = "Permisos de lectura y escritura en DynamoDB"
    statements = [
      {
        sid    = "DynamoDBReadWrite"
        effect = "Allow"
        actions = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        resources = [
          "arn:aws:dynamodb:us-east-1:*:table/my-table"
        ]
      }
    ]
  }

  # Política para publicar en SNS
  sns_publish = {
    policy_description = "Permisos para publicar mensajes en SNS"
    statements = [
      {
        sid    = "SNSPublish"
        effect = "Allow"
        actions = [
          "sns:Publish"
        ]
        resources = [
          "arn:aws:sns:us-east-1:*:my-topic"
        ]
      }
    ]
  }
}

################################################################################
# CONFIGURACIÓN ADICIONAL (OPCIONAL)
################################################################################

# Duración máxima de sesión en segundos (1 hora por defecto)
# Rango: 3600 (1 hora) a 43200 (12 horas)
max_session_duration = 3600

# Path del rol IAM (por defecto "/")
path = "/"

# ARN del permissions boundary (opcional)
# Limita los permisos máximos que puede tener el rol
# permissions_boundary = "arn:aws:iam::123456789012:policy/MyBoundaryPolicy"

################################################################################
# TAGS
# Tags adicionales para aplicar a los recursos creados
################################################################################

tags = {
  owner       = "devteam"
  cost_center = "engineering"
  application = "myapp"
}
