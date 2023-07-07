locals {
  cluster_name        = var.cluster_name
  aws_region          = var.aws_region
  account_id          = var.account_id
  cidr                = var.cidr
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  cluster_version     = var.cluster_version
  capacity_type       = var.capacity_type
  aws_auth_users      = var.aws_auth_users
  kms_key_owners      = var.kms_key_owners
  desired_worker_node = var.desired_worker_node
  max_worker_node     = var.max_worker_node
  min_worker_node     = var.min_worker_node
  disk_size           = var.disk_size
  instance_types      = var.instance_types
}
