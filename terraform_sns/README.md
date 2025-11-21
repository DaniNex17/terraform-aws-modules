# Módulo Terraform SNS

## Descripción:

Este módulo de Terraform permite la creación de tópicos en Amazon SNS junto con suscripciones y políticas asociadas. Automatiza la configuración de temas, suscripciones a distintos destinos y políticas de acceso para notificaciones en la nube.

## Estructura del Módulo

El módulo cuenta con la siguiente estructura:

```bash
.
├── modules
│   └── sns
│       ├── data.tf
│       ├── iam.tf
│       ├── inputs.tf
│       ├── locals.tf
│       ├── outputs.tf
│       ├── sns.tf
│       └── versions.tf
└── samples
    └── sns
        ├── data.tf
        ├── inputs.tf
        ├── main.tf
        ├── outputs.tf
        └── sample.auto.tfvars
```

- `/modules`: contiene toda la configuración de los recursos del módulo.
- `/samples`: contiene ejemplo de implementación del módulo.

## Funcionalidades Principales:

- `aws_sns_topic`: Crea un tema de SNS con cifrado KMS. El nombre se genera dinámicamente y la clave KMS es configurable (por defecto usa `alias/aws/sns`).
- `aws_sns_topic_subscription`: Crea suscripciones al tema de SNS para diferentes endpoints. Soporta protocolos como HTTP, email, SQS, Lambda, entre otros.
- `aws_sns_topic_policy`: Define la política asociada al tema de SNS, controlando los permisos de acceso mediante un documento de política IAM.
- `aws_iam_role` (opcional): Crea roles y políticas IAM para habilitar logs de SNS en CloudWatch cuando se activa la opción.

## Definición de variables:

Para utilizar el módulo, es necesario proporcionar las variables requeridas. Esto puede hacerse por medio de un archivo `.auto.tfvars` o `terraform.tfvars`:

| Clave | Descripción | Tipo | Valor por defecto | Obligatorio |
|-------|-------------|------|-------------------|-------------|
| `name` | Nombre del topic SNS | `string` | <center>N/A | <center>✅ |
| `kms_master_key` | KMS para cifrar el topic SNS, puede enviar el ARN, ID o ALIAS de KMS | `string` | <center>`alias/aws/sns` | <center>⛔ |
| `tags` | Tags adicionales para aplicar a los recursos creados | `map(string)` | <center>`{}` | <center>⛔ |
| `subscriptions` | Listado de suscripciones al topic | `list(object({protocol = string, endpoint = string}))` | <center>`[]` | <center>⛔ |
| `sns_policy` | Políticas personalizadas para el topic SNS | `list(object({}))` | <center>`[]` | <center>⛔ |
| `enable_cloudwatch_logs` | Habilitar logs de SNS en CloudWatch | `bool` | <center>`false` | <center>⛔ |
| `sqs_success_feedback_rate` | Tasa de muestra de éxito para logs SQS (0-100%) | `number` | <center>`45` | <center>⛔ |

## Definición de variables desglosadas:

- **subscriptions**:

| Clave | Descripción | Tipo | Valor por defecto | Obligatorio |
|-------|-------------|------|-------------------|-------------|
| `protocol` | Define el protocolo de comunicación que SNS utilizará para enviar notificaciones al endpoint | `string` | <center>N/A | <center>✅ |
| `endpoint` | Define la dirección a la que SNS enviará las notificaciones | `string` | <center>N/A | <center>✅ |

- **sns_policy**:

| Clave | Descripción | Tipo | Valor por defecto | Obligatorio |
|-------|-------------|------|-------------------|-------------|
| `actions` | Una lista de cadenas que especifican las acciones permitidas en la política | `list(string)` | N/A | <center>✅ |
| `resources` | Una lista de cadenas que especifican los recursos a los que se aplica la política | `list(string)` | N/A | <center>✅ |
| `effect` | Una cadena que indica el efecto de la política ("Allow" o "Deny") | `string` | N/A | <center>✅ |
| `principals` | Una lista de objetos, donde cada objeto tiene: <br>**type**: un string que indica el tipo de principal (p.ej., AWS, Service). <br>**identifiers**: una lista de strings que representan los identificadores de los principals | `list(object)` | N/A | <center>✅ |
| `sid` | Una cadena o nulo que proporciona un identificador único para la política | `string` | `null` | <center>⛔ |
| `condition` | Una lista opcional de objetos, donde cada objeto tiene: <br>**test**: un string que indica la condición a probar. <br>**variable**: un string que representa la variable en la condición. <br>**values**: una lista de strings que representan los valores para la condición | `list(object)` | `[]` | <center>⛔ |

## Dependencias del módulo:

- Por defecto, el módulo usa la clave KMS administrada por AWS (`alias/aws/sns`). Si deseas usar una clave KMS personalizada, debes proporcionarla.
- Para suscripciones a SQS, la cola debe tener una política que permita a SNS enviar mensajes.

## Versiones:

| Versión | Descripción | Versión Terraform | Versión Provider |
|---------|-------------|-------------------|------------------|
| <center>`v0.0.1` | Versión inicial del módulo SNS personal. Incluye creación de topics, suscripciones, políticas y soporte opcional para logs en CloudWatch | <center>`>= 1.0` | <center>`AWS >= 5.0` |

## Integración:

Este módulo no posee integraciones actualmente con otras arquitecturas.

## Consideraciones de Seguridad:

- El módulo implementa cifrado KMS por defecto usando `alias/aws/sns`
- Todas las políticas incluyen validación de `aws:SecureTransport` para forzar conexiones seguras
- Las políticas con wildcards (`*`) en principals requieren condiciones adicionales
- Se recomienda usar KMS keys personalizadas para mayor control de seguridad

## Ejemplo de Uso:

### Configuración básica:

```hcl
module "simple_sns" {
  source = "../../modules/sns"

  name          = "my-sns-topic"
  subscriptions = [
    {
      protocol = "sqs"
      endpoint = "arn:aws:sqs:us-east-1:123456789012:my-queue"
    }
  ]

  sns_policy = [{
    actions   = ["SNS:Publish"]
    effect    = "Allow"
    resources = ["*"]
    sid       = "AllowPublish"
    principals = [{
      type        = "AWS"
      identifiers = ["123456789012"]
    }]
  }]

  tags = {
    environment = "dev"
    project     = "personal"
  }
}
```

### Configuración completa con logs:

```hcl
module "complete_sns" {
  source = "../../modules/sns"

  name           = "my-sns-topic-complete"
  kms_master_key = "alias/my-custom-kms-key"

  subscriptions = [
    {
      protocol = "sqs"
      endpoint = "arn:aws:sqs:us-east-1:123456789012:my-queue"
    },
    {
      protocol = "email"
      endpoint = "alerts@example.com"
    }
  ]

  enable_cloudwatch_logs    = true
  sqs_success_feedback_rate = 50

  sns_policy = [{
    actions   = ["SNS:Publish"]
    effect    = "Allow"
    resources = ["*"]
    sid       = "AllowPublish"
    principals = [{
      type        = "AWS"
      identifiers = ["123456789012"]
    }]
    condition = [{
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["123456789012"]
    }]
  }]

  tags = {
    environment = "production"
    project     = "personal"
  }
}
```

Tener presente que las variables deben configurarse según la especificación de la sección de variables.

## Referencia de outputs

El módulo exporta las siguientes variables para su uso:

| Output | Valor | Descripción |
|--------|-------|-------------|
| `arn` | `aws_sns_topic.main.arn` | ARN del topic SNS |

## Colaboradores

| Fecha | Descripción | Realizó |
|-------|-------------|---------|
| 2025/11/17 | Versión 0.0.1 - Creación inicial del módulo SNS | Daniel Fernando Vidal Morillo |
