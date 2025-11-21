# IAM Role
resource "aws_iam_role" "main_role" {
  name                 = var.role_name
  assume_role_policy   = var.assume_role_policy
  description          = var.description
  path                 = var.path
  max_session_duration = var.max_session_duration
  permissions_boundary = var.permissions_boundary

  tags = local.resource_tags
}

# Custom IAM Policies (creadas desde role_policies)
resource "aws_iam_policy" "policy" {
  for_each = var.role_policies

  name        = "${var.role_name}-${each.key}"
  description = each.value.policy_description
  policy      = data.aws_iam_policy_document.policies[each.key].json

  tags = local.resource_tags
}

# Attach custom policies to role
resource "aws_iam_role_policy_attachment" "role_policy" {
  for_each = var.role_policies

  role       = aws_iam_role.main_role.name
  policy_arn = aws_iam_policy.policy[each.key].arn

  depends_on = [
    aws_iam_role.main_role,
    aws_iam_policy.policy
  ]
}

# Attach AWS managed policies to role
resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.main_role.name
  policy_arn = each.value

  depends_on = [aws_iam_role.main_role]
}