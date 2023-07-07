locals {
  cluster_name      = var.cluster_name
  aws_region        = var.aws_region
  account_id        = var.account_id
  cidr              = var.cidr
  private_subnets   = var.private_subnets
  public_subnets    = var.public_subnets
  cluster_version   = var.cluster_version
  capacity_type     = var.capacity_type
  aws_auth_users    = var.aws_auth_users
  kms_key_owners    = var.kms_key_owners
}
