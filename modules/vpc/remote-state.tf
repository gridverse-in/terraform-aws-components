module "vpc_flow_logs_bucket" {
  count = local.vpc_flow_logs_enabled ? 1 : 0

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "vpc-flow-logs-bucket"
  environment = var.vpc_flow_logs_bucket_environment_name
  stage       = var.vpc_flow_logs_bucket_stage_name
  tenant      = try(coalesce(var.vpc_flow_logs_bucket_tenant_name, module.this.tenant), null)

  context = module.this.context
}


module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "account-map"
  environment = var.account_map_environment_name
  stage       = var.account_map_stage_name
  tenant      = coalesce(var.account_map_tenant_name, module.this.tenant)

  context = module.this.context
}
