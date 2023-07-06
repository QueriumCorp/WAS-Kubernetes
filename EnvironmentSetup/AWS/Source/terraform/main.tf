terraform {
  backend "s3" {
    bucket         = "terraform-tfstate-${var.cluster-name}"
    key            = "global/s3/terraform.tfstate"
    region         = "${var.aws_region}"
    dynamodb_table = "${var.dynamodb_table}"
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
  region = var.aws_region
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_availability_zones" "available" {
}

module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "~> 3.18"
  name                   = "${var.cluster-name}-vpc"
  cidr                   = "10.168.0.0/16"
  azs                    = data.aws_availability_zones.available.names
  private_subnets        = ["10.168.128.0/18", "10.168.192.0/18"]
  public_subnets         = ["10.168.0.0/18", "10.168.64.0/18"]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_dns_hostnames   = true


  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
  
  tags = {
    Terraform = "true"
    Environment = "${var.cluster-name}"
  }

}

module "eks" {
  source                    = "terraform-aws-modules/eks/aws"
  version                   = "~> 19.4"
  cluster_name              = var.cluster-name
  cluster_version           = var.cluster-version
  subnets                   = module.vpc.private_subnets
  vpc_id                    = module.vpc.vpc_id
  write_kubeconfig          = false
  cluster_create_timeout    = "120m"
  
  tags = {
    Environment = "Wolfram Application Server"
  }

  eks_managed_node_groups = {
    eks = {
      name              = "${var.cluster-name}-worker-nodes"
      capacity_type     = "SPOT"
      enable_monitoring = false
      desired_capacity  = var.desired-worker-node
      max_capacity      = var.max-worker-node
      min_capacity      = var.min-worker-node
      disk_size         = var.disk-size
      instance_types    = [var.instance_type]

      labels = {
        node-group = "live"
      }

    }
  }

  workers_additional_policies = [aws_iam_policy.worker_policy.arn]
}

resource "aws_iam_policy" "worker_policy" {
  name        = "node-workers-policy-${var.cluster-name}"
  description = "Node Workers IAM policies"

  policy = file("${path.module}/iam-policy.json")
}
