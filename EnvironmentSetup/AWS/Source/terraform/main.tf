# need this bc the default aws profile specifies us-east-2
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}


module "vpc" {
    source = "./modules/vpc"
    
    shared_resource_name = var.shared_resource_name
    account_id = var.account_id
    aws_region = var.aws_region
    aws_profile = var.aws_profile
    cidr = var.cidr
    private_subnets = var.private_subnets
    public_subnets = var.public_subnets
}

module "eks" {
    source = "./modules/eks"

    shared_resource_name = var.shared_resource_name
    account_id = var.account_id
    aws_region = var.aws_region
    aws_profile = var.aws_profile
    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets
    namespace = var.namespace
    cluster_version = var.cluster_version
    disk_size = var.disk_size
    instance_types = var.instance_types
    desired_worker_node = var.desired_worker_node
    min_worker_node = var.min_worker_node
    max_worker_node = var.max_worker_node
    capacity_type = var.capacity_type
    aws_auth_users = var.aws_auth_users
    kms_key_owners = var.kms_key_owners
}