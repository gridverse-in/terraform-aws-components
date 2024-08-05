locals {
  enable_resource_share = local.enabled && length(var.shared_with_accounts) > 0


  public_subnet_arns_map = {
    for idx, arn in tolist(module.subnets.public_subnet_arns) : idx => arn
  }

  private_subnet_arns_map = {
    for idx, arn in tolist(module.subnets.private_subnet_arns) : idx => arn
  }
}

# Resource Access Manager (RAM) share for the subnets
# https://docs.aws.amazon.com/ram/latest/userguide/what-is.html
resource "aws_ram_resource_share" "default" {
  count                     = local.enable_resource_share ? 1 : 0
  name                      = module.this.id
  allow_external_principals = false
  tags                      = module.this.tags
}

resource "aws_ram_resource_association" "public_subnets" {
  for_each           = local.enable_resource_share ? local.public_subnet_arns_map : {}
  resource_arn       = each.value
  resource_share_arn = aws_ram_resource_share.default[0].id
}

resource "aws_ram_resource_association" "private_subnets" {
  for_each           = local.enable_resource_share ? local.private_subnet_arns_map : {}
  resource_arn       = each.value
  resource_share_arn = aws_ram_resource_share.default[0].id
}

resource "aws_ram_principal_association" "accounts" {
  for_each           = local.enable_resource_share ? var.shared_with_accounts : []
  principal          = module.account_map.outputs.full_account_map[each.value]
  resource_share_arn = aws_ram_resource_share.default[0].id
}
