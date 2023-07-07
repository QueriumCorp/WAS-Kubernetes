# -----------------------------------------------------------------------------
# module configuration
# -----------------------------------------------------------------------------
module "common_config" {
   source = "../common_config"
}

locals {
  shared_resource_name      = module.common_config.shared_resource_name
  aws_region        = module.common_config.aws_region
  account_id        = module.common_config.account_id
  cidr              = module.common_config.cidr
  private_subnets   = module.common_config.private_subnets
  public_subnets    = module.common_config.public_subnets
  cluster_version   = module.common_config.cluster_version
  capacity_type     = module.common_config.capacity_type
  aws_auth_users    = module.common_config.aws_auth_users
  kms_key_owners    = module.common_config.kms_key_owners
}
