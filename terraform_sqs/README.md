# Módulo Terraform SQS

## Descripción

Este módulo de Terraform permite la creación de colas SQS (Simple Queue Service) de AWS junto con sus políticas de seguridad asociadas. Proporciona una solución completa y segura para implementar colas de mensajes en microservicios, sistemas distribuidos y aplicaciones sin servidor.

## Estructura del Módulo

El módulo cuenta con la siguiente estructura:

```bash
├── modules
│   └── sqs
│       ├── data.tf
│       ├── iam.tf
│       ├── inputs.tf
│       ├── outputs.tf
│       ├── sqs.tf
│       └── versions.tf
└── samples
    └── sqs
        ├── inputs.tf
        ├── main.tf
        ├── sample.auto.tfvars
        └── README.md
```

- `/modules/sqs`: Contiene toda la configuración de los recursos del módulo
- `/samples/sqs`: Contiene ejemplos de implementación del módulo

> **Nota**: Los ejemplos en `/samples` no incluyen outputs. Para verificar los recursos creados, accede directamente a la consola de AWS o usa AWS CLI.

## Funcionalidades Principales

- **aws_sqs_queue**: Crea una cola SQS con configuración completa y flexible
- **aws_sqs_queue_policy**: Define políticas de acceso estructuradas con seguridad por defecto
- **Cifrado**: Soporte para cifrado con KMS o cifrado por defecto de AWS
- **Dead Letter Queue (DLQ)**: Configuración bidireccional para DLQs
- **Colas FIFO**: Soporte completo para colas FIFO con todas sus opciones
- **Permisos Flexibles**: Sistema de permisos adicionales para casos avanzados
- **Seguridad**: Política que deniegue tráfico no cifrado (SecureTransport)

## Definición de Variables

Para utilizar el módulo, es necesario proporcionar las variables requeridas. Como puede verse en la carpeta `samples`, esto puede hacerse por medio de un archivo `.auto.tfvars` o `terraform.tfvars`:

| Variable | Descripción | Tipo | Valor por defecto | Obligatorio |
|----------|-------------|------|-------------------|-------------|
| `queue_name` | Nombre de la cola SQS | `string` | N/A | ✅ |
| `use_name_prefix` | Determina si el nombre se utiliza como prefijo | `bool` | `false` | ⛔ |
| `delay_seconds` | Tiempo de retraso para entregar mensajes (0-900 segundos) | `number` | `0` | ⛔ |
| `max_message_size` | Tamaño máximo del mensaje en bytes (1024-262144) | `number` | `262144` | ⛔ |
| `message_retention_seconds` | Tiempo de retención de mensajes en segundos (60-1209600) | `number` | `345600` | ⛔ |
| `receive_wait_time_seconds` | Tiempo de espera para long polling (0-20 segundos) | `number` | `0` | ⛔ |
| `visibility_timeout_seconds` | Tiempo de timeout de visibilidad (0-43200 segundos) | `number` | `30` | ⛔ |
| `fifo_queue` | Habilita el modo FIFO | `bool` | `false` | ⛔ |
| `fifo_throughput_limit` | Límite de rendimiento de la cola FIFO | `string` | `"perQueue"` | ⛔ |
| `content_based_deduplication` | Habilita deduplicación basada en contenido | `bool` | `false` | ⛔ |
| `deduplication_scope` | Alcance para la eliminación de contenido duplicado | `string` | `"queue"` | ⛔ |
| `kms_master_key_id` | ID de la KMS key para cifrado | `string` | `null` | ⛔ |
| `kms_data_key_reuse_period_seconds` | Período de reutilización de la data key de KMS (60-86400) | `number` | `300` | ⛔ |
| `redrive_policy` | Configuración de Dead Letter Queue | `object` | `null` | ⛔ |
| `arn_sqs_source_to_this_dlq` | ARNs de colas que usan esta como DLQ | `list(string)` | `null` | ⛔ |
| `extra_permissions` | Permisos adicionales para la cola | `list(object)` | `[]` | ⛔ |
| `tags` | Tags para aplicar a la cola | `map(string)` | `{}` | ⛔ |

### Variables Desglosadas

#### 1. `redrive_policy`

| Atributo | Descripción | Tipo | Obligatorio |
|----------|-------------|------|-------------|
| `deadLetterTargetArn` | ARN del Dead Letter Queue al que se desea redirigir los mensajes | `string` | ✅ |
| `maxReceiveCount` | Número de veces que un consumidor puede recibir un mensaje antes de pasarlo a un DLQ | `number` | ✅ |

#### 2. `extra_permissions`

| Atributo | Descripción | Tipo | Obligatorio |
|----------|-------------|------|-------------|
| `effect` | Indica si la acción debe permitir o denegar (`Allow` o `Deny`) | `string` | ✅ |
| `actions` | Lista de acciones de AWS que se permiten o deniegan | `list(string)` | ✅ |
| `resources` | Lista de recursos AWS a los que aplica la política | `list(string)` | ✅ |
| `principals` | Lista de principals (type e identifiers) | `list(object)` | ✅ |
| `sid` | Identificador único opcional para la declaración | `string` | ⛔ |
| `condition` | Lista opcional de condiciones (test, variable, values) | `list(object)` | ⛔ |

## Dependencias del Módulo

### Cifrado KMS
- Para habilitar el cifrado con KMS, es necesario tener creada previamente una clave KMS
- Si la variable `kms_master_key_id` se pasa en `null`, se cifran los mensajes con la llave administrada de AWS (SSE-SQS)

### Gestión de Dead Letter Queue (DLQ)
- Para habilitar la cola como DLQ, la variable `arn_sqs_source_to_this_dlq` debe tener el o los ARN correspondientes a las colas que enviarían mensajes a este DLQ en caso de fallo
- Si se requiere que una cola envíe mensajes a un DLQ, debe enviarse el parámetro `redrive_policy` con:
  - `maxReceiveCount`: Número de veces que un consumidor puede recibir un mensaje antes de pasarlo a un DLQ
  - `deadLetterTargetArn`: ARN del Dead Letter Queue al que se desea redirigir los mensajes

## Ejemplo de Uso

### Cola Simple

```hcl
module "simple_sqs" {
  source = "./modules/sqs"

  queue_name                = "my-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 10

  tags = {
    environment = "dev"
    project     = "my-project"
  }
}
```

### Cola con Cifrado KMS

```hcl
module "encrypted_sqs" {
  source = "./modules/sqs"

  queue_name        = "my-encrypted-queue"
  kms_master_key_id = "alias/aws/sqs"  # o tu KMS key ARN

  tags = {
    environment = "production"
  }
}
```

### Cola FIFO

```hcl
module "fifo_sqs" {
  source = "./modules/sqs"

  queue_name                  = "my-fifo-queue"
  fifo_queue                  = true
  content_based_deduplication = true
  deduplication_scope         = "queue"
  fifo_throughput_limit       = "perQueue"

  tags = {
    environment = "production"
  }
}
```

### Cola con Dead Letter Queue

```hcl
# Primero crear la DLQ
module "dlq" {
  source = "./modules/sqs"

  queue_name                = "my-dlq"
  message_retention_seconds = 1209600  # 14 días

  tags = {
    type = "dlq"
  }
}

# Luego crear la cola principal con redrive policy
module "main_queue" {
  source = "./modules/sqs"

  queue_name = "my-main-queue"

  redrive_policy = {
    deadLetterTargetArn = module.dlq.sqs_queue_arn
    maxReceiveCount     = 5
  }

  tags = {
    environment = "production"
  }
}

# Configurar la DLQ para aceptar mensajes de la cola principal
module "dlq_configured" {
  source = "./modules/sqs"

  queue_name = "my-dlq"
  
  arn_sqs_source_to_this_dlq = [
    module.main_queue.sqs_queue_arn
  ]

  tags = {
    type = "dlq"
  }
}
```

### Cola con Permisos Adicionales

```hcl
module "sqs_with_lambda" {
  source = "./modules/sqs"

  queue_name = "my-queue-for-lambda"

  extra_permissions = [
    {
      effect    = "Allow"
      actions   = ["SQS:SendMessage"]
      resources = ["*"]
      sid       = "AllowLambdaSendMessage"
      principals = [
        {
          type        = "Service"
          identifiers = ["lambda.amazonaws.com"]
        }
      ]
      condition = [
        {
          test     = "ArnEquals"
          variable = "aws:SourceArn"
          values   = ["arn:aws:lambda:us-east-1:123456789012:function:my-function"]
        }
      ]
    }
  ]

  tags = {
    environment = "production"
  }
}
```

## Consideraciones de Seguridad

Este módulo implementa las siguientes medidas de seguridad:

- **Cifrado en reposo**: Soporte para cifrado con KMS o cifrado por defecto de AWS (SSE-SQS)
- **Cifrado en tránsito**: Política que deniegue acceso sin HTTPS (SecureTransport = false)
- **Políticas estructuradas**: Uso de `aws_iam_policy_document` para políticas IAM bien formadas
- **Permisos mínimos**: Política base que solo permite acceso desde la cuenta actual
- **Validaciones**: Todas las variables críticas tienen validaciones de rango

## Referencia de Outputs

El módulo exporta las siguientes variables para su uso cuando lo integres en tu código:

| Output | Valor | Descripción |
|--------|-------|-------------|
| `sqs_queue_name` | `aws_sqs_queue.this.name` | Nombre de la cola SQS |
| `sqs_queue_arn` | `aws_sqs_queue.this.arn` | ARN de la cola SQS |
| `sqs_queue_id` | `aws_sqs_queue.this.id` | ID/URL de la cola SQS |
| `sqs_queue_url` | `aws_sqs_queue.this.url` | URL de la cola SQS |

### Ejemplo de uso de outputs:

```hcl
module "my_queue" {
  source     = "./modules/sqs"
  queue_name = "my-queue"
}

# Usar los outputs en otros recursos
resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn = module.my_queue.sqs_queue_arn
  function_name    = aws_lambda_function.example.arn
}

# O exportarlos en tus propios outputs
output "queue_url" {
  value = module.my_queue.sqs_queue_url
}
```

## Versiones

| Versión | Descripción | Versión Terraform | Versión Provider |
|---------|-------------|-------------------|------------------|
| `v1.0.0` | Versión inicial del módulo de SQS con mejores prácticas de seguridad | `>= 1.0` | `AWS >= 5.0` |

## Notas Importantes

- **Cambio de tipo de cola**: Si cambia de cola estándar a FIFO o viceversa, la cola será recreada (destruida y creada nuevamente)
- **Sufijo FIFO**: Para colas FIFO, el módulo agrega automáticamente el sufijo `.fifo` al nombre
- **Long polling**: Se recomienda usar `receive_wait_time_seconds` entre 1-20 para habilitar long polling y reducir costos
- **Retención de mensajes**: El valor por defecto es 4 días (345600 segundos), pero puede configurarse hasta 14 días

## Colaboradores
| Fecha | Descripción | Realizó |
|-------|-------------|---------|
| 2025/11/17 | Versión 0.0.1 | Daniel Fernando Vidal Morillo |


