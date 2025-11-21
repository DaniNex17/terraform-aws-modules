locals {
  resource_tags = merge(
    {
      managed_by = "terraform"
      module     = "sns"
    },
    var.tags
  )
}
