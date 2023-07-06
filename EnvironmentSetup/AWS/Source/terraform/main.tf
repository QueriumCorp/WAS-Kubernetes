locals {
  cluster_name    = var.cluster-name
  aws_region      = var.aws_region
  account_id      = var.account_id
}

terraform {
  backend "s3" {
    bucket         = "320713933456-terraform-tfstate-was-01"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking-was"
    encrypt        = true
  }

  required_version = "~> 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48"
    }
  }
}

provider "aws" {
  region = local.aws_region
}

data "aws_availability_zones" "available" {
}

module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "~> 3.18"
  name                   = "${local.cluster_name}-vpc"
  cidr                   = "10.168.0.0/16"
  azs                    = data.aws_availability_zones.available.names
  private_subnets        = ["10.168.128.0/18", "10.168.192.0/18"]
  public_subnets         = ["10.168.0.0/18", "10.168.64.0/18"]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_dns_hostnames   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
  
  tags = {
    Terraform = "true"
    Environment = "${local.cluster_name}"
  }

}

module "eks" {
  source                      = "terraform-aws-modules/eks/aws"
  version                     = "~> 19.4"
  cluster_name                = local.cluster_name
  cluster_version             = var.cluster-version
  subnet_ids                  = module.vpc.private_subnets
  vpc_id                      = module.vpc.vpc_id
  create_cloudwatch_log_group = false
  
  tags = {
    Environment = "Wolfram Application Server"
  }

  create_kms_key            = true
  manage_aws_auth_configmap = true
  aws_auth_users            = [
    {
      userarn  = "arn:aws:iam::${local.account_id}:user/mcdaniel"
      username = "mcdaniel"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::${local.account_id}:user/kent.fuka"
      username = "kent.fuka"
      groups   = ["system:masters"]
    },
  ]
  kms_key_owners = [
    "arn:aws:iam::${local.account_id}:user/mcdaniel",
    "arn:aws:iam::${local.account_id}:user/kent.fuka",
  ]

  eks_managed_node_groups = {
    eks = {
      name              = "${local.cluster_name}-worker-nodes"
      capacity_type     = "SPOT"
      enable_monitoring = false
      desired_capacity  = var.desired-worker-node
      max_capacity      = var.max-worker-node
      min_capacity      = var.min-worker-node
      disk_size         = var.disk-size
      instance_types    = [var.instance_type]

      labels = {
        node-group = "was"
      }

    }
  }

  iam_role_additional_policies = {
      WorkersAdditionalPolicies = aws_iam_policy.worker_policy.arn
  }

}

resource "aws_iam_policy" "worker_policy" {
  name        = "node-workers-policy-${local.cluster_name}"
  description = "Node Workers IAM policies"

  policy = file("${path.module}/iam-policy.json")
}
