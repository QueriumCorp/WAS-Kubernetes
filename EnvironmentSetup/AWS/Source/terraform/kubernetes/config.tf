# -----------------------------------------------------------------------------
# module configuration
# -----------------------------------------------------------------------------
module "common_config" {
   source = "../config"
}

locals {
  # common settings
  cluster_name        = module.common_config.cluster_name
  aws_region          = module.common_config.aws_region
  account_id          = module.common_config.account_id
  cidr                = module.common_config.cidr

  # vpc settings
  private_subnets     = module.common_config.private_subnets
  public_subnets      = module.common_config.public_subnets

  # eks settings
  cluster_version     = module.common_config.cluster_version
  aws_auth_users      = module.common_config.aws_auth_users
  kms_key_owners      = module.common_config.kms_key_owners

  # eks managed node group settings
  desired_worker_node = module.common_config.desired_worker_node
  capacity_type       = module.common_config.capacity_type
  max_worker_node     = module.common_config.max_worker_node
  min_worker_node     = module.common_config.min_worker_node
  disk_size           = module.common_config.disk_size
  instance_types      = module.common_config.instance_types
}
