# Módulo Terraform IAM

## Descripción:

Este módulo facilita la creación de roles IAM en AWS de forma flexible. Permite crear roles con políticas gestionadas de AWS y políticas personalizadas.

## Estructura del Módulo

El módulo cuenta con la siguiente estructura:

```bash
.
├── README.md
├── modules
│   └── role
│       ├── data.tf
│       ├── inputs.tf
│       ├── locals.tf
│       ├── outputs.tf
│       ├── role.tf
│       └── versions.tf
└── samples
    └── role
        ├── inputs.tf
        ├── main.tf
        ├── outputs.tf
        └── sample.auto.tfvars
```

- `/modules`: contiene toda la configuración de los recursos del módulo.
- `/samples`: contiene ejemplo de implementación genérico y reutilizable.

## Funcionalidades Principales:

- `aws_iam_role`: Este recurso representa un rol en AWS IAM. Un rol es una entidad que se puede asignar a servicios de AWS para otorgarles permisos específicos.
- `aws_iam_policy`: Este recurso representa una política personalizada en AWS IAM. Define los permisos y las acciones permitidas en AWS.
- `aws_iam_role_policy_attachment`: Este recurso representa la asociación entre un rol y una política en AWS IAM. Permite adjuntar políticas (gestionadas o personalizadas) a un rol específico.

## Definición de variables:

Para poder utilizar el módulo, es necesario que le entreguemos las variables requeridas. Como puede verse en la carpeta `samples` esto puede hacerse por medio de un archivo `sample.auto.tfvars`:

| Clave | Descripción | Tipo | Valor por defecto | Obligatorio |
|-------|-------------|------|-------------------|-------------|
| `role_name` | Nombre del rol IAM | `string` | <center>N/A | <center>✅ |
| `assume_role_policy` | Política de asunción que define quién puede usar el rol | `string` | <center>N/A | <center>✅ |
| `description` | Descripción del rol | `string` | <center>"" | <center>⛔ |
| `managed_policy_arns` | Lista de ARNs de políticas gestionadas de AWS | `list(string)` | <center>[] | <center>⛔ |
| `role_policies` | Mapa de políticas personalizadas para el rol | `map(object({}))` | <center>{} | <center>⛔ |
| `tags` | Tags adicionales para aplicar a los recursos creados | `map(string)` | <center>{} | <center>⛔ |
| `max_session_duration` | Duración máxima de sesión en segundos | `number` | <center>3600 | <center>⛔ |
| `path` | Path del rol IAM | `string` | <center>"/" | <center>⛔ |
| `permissions_boundary` | ARN del permissions boundary (opcional) | `string` | <center>null | <center>⛔ |

### Variables desglosadas

- **role_policies**:

| Clave | Descripción | Tipo | Valor por defecto | Obligatorio |
|-------|-------------|------|-------------------|-------------|
| `policy_description` | Descripción que tendrá la política | `string` | <center>N/A | <center>✅ |
| `statements` | Una lista de objetos que contiene los statements de cada política | `list(object({}))` | <center>N/A | <center>✅ |

- **role_policies.statements**:

| Clave | Descripción | Tipo | Valor por defecto | Obligatorio |
|-------|-------------|------|-------------------|-------------|
| `actions` | Una lista de cadenas (strings) que especifican las acciones permitidas en la política | `list(string)` | N/A | <center>✅ |
| `resources` | Una lista de cadenas (strings) que especifican los recursos a los que se aplica la política | `list(string)` | N/A | <center>✅ |
| `effect` | Una cadena (string) que indica el efecto de la política ("Allow" o "Deny") | `string` | N/A | <center>✅ |
| `sid` | Una cadena (string) o nulo que proporciona un identificador único para la política | `string` | null | <center>⛔ |
| `condition` | Una lista opcional de objetos con condiciones: <br>**test**: un string que indica la condición a probar <br>**variable**: un string que representa la variable en la condición <br>**values**: una lista de strings que representan los valores para la condición | `list(object)` | [] | <center>⛔ |

## Dependencias del módulo:

- **Terraform** >= 1.0
- **AWS Provider** >= 5.0
- **AWS CLI** configurado con credenciales
- **Permisos IAM** para crear roles y políticas

## Versiones:

| Versión | Descripción | Versión Terraform | Versión Provider |
|---------|-------------|-------------------|------------------|
| <center>`0.0.1` | Versión inicial del módulo. Implementación flexible para creación de roles IAM con políticas gestionadas y personalizadas. | <center>`>= 1.0` | <center>`AWS >= 5.0` |

## Consideraciones de Seguridad:

- El módulo permite la creación de políticas personalizadas con control granular de permisos
- Soporta el uso de conditions en las políticas para mayor seguridad
- Permite configurar permissions boundary para limitar permisos máximos
- Se recomienda seguir el principio de mínimo privilegio al definir políticas

## Ejemplo de Uso:

### Ejemplo Mínimo (Solo managed policies)

```hcl
module "simple_role" {
  source = "./modules/role"
  
  role_name   = "role-lambda-myproject-dev"
  description = "Rol básico para Lambda"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  
  tags = {
    environment = "dev"
    project     = "myproject"
    owner       = "devteam"
  }
}
```

### Ejemplo Completo (Managed + Custom policies)

```hcl
module "complete_role" {
  source = "./modules/role"
  
  role_name   = "role-lambda-myproject-dev"
  description = "Rol completo para Lambda con acceso a S3 y DynamoDB"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  
  # Políticas gestionadas de AWS
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  
  # Políticas personalizadas
  role_policies = {
    s3_access = {
      policy_description = "Acceso a S3"
      statements = [{
        sid    = "S3ReadWrite"
        effect = "Allow"
        actions = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        resources = [
          "arn:aws:s3:::my-bucket/*"
        ]
      }]
    }
    
    dynamodb_access = {
      policy_description = "Acceso a DynamoDB"
      statements = [{
        effect = "Allow"
        actions = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query"
        ]
        resources = [
          "arn:aws:dynamodb:us-east-1:*:table/my-table"
        ]
      }]
    }
  }
  
  tags = {
    environment = "dev"
    project     = "myproject"
    owner       = "devteam"
  }
}
```

## Referencia de outputs

El módulo exporta las siguientes variables para su uso:

| Output | Valor | Descripción |
|--------|-------|-------------|
| `role_arn` | `aws_iam_role.this.arn` | ARN del rol creado |
| `role_name` | `aws_iam_role.this.name` | Nombre del rol creado |
| `role_policy_arn` | `values(aws_iam_policy.custom_policy)[*].arn` | ARNs de las políticas creadas |
| `role_policy_name` | `values(aws_iam_policy.custom_policy)[*].name` | Nombres de las políticas creadas |
```

## Colaboradores

| Fecha | Descripción | Realizó |
|-------|-------------|---------|
| 2025/11/15 | Versión 0.0.1 - Creación inicial del módulo IAM | Daniel Fernando Vidal Morillo |
