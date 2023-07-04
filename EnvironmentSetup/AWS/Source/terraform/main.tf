terraform {
  backend "s3" {
    bucket         = "${account_id}-terraform-tfstate-${var.cluster-name}"
    key            = "global/s3/terraform.tfstate"
    region         = "${var.aws_region}"
    dynamodb_table = "${var.dynamodb_table}"
    encrypt        = true
  }
  required_version = "~> 1.2.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.75.2"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "cluster" {
  name = data.aws_eks_cluster.cookiecutter.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.aws_eks_cluster.cookiecutter.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_availability_zones" "available" {
}

###############################################################################
#                                RESOURCES
###############################################################################

#------------------------------------------------------------------------------
# swap out newly created vpc and eks for for our preexisting resources
#------------------------------------------------------------------------------
data "aws_vpc" "cookiecutter" {
  filter = {
    name = "Name",
    value = "${var.cookiecutter_common_resource_name}"
  }
}

data "aws_eks_cluster" "cookiecutter" {
  name = "${var.cookiecutter_common_resource_name}"
}


resource "kubernetes_namespace" "was" {
  metadata {
    name = "was"
  }
  depends_on = [data.data.aws_eks_cluster.cookiecutter]
}

# MCDANIEL NOTE: dedicated managed node group for WAF added to openedx_devops


# module "eks" {
#   source                    = "terraform-aws-modules/eks/aws"
#   version                   = "16.1.0"
#   cluster_name              = var.cluster-name
#   cluster_version           = var.cluster-version
#   subnets                   = data.aws_vpc.cookiecutter.private_subnets
#   vpc_id                    = data.aws_vpc.cookiecutter.vpc_id
#   write_kubeconfig          = false
#   cluster_create_timeout    = "120m"
  
#   tags = {
#     Environment = "Wolfram Application Server"
#   }

#   node_groups = {
#     eks = {
#       name             = "${var.cluster-name}-worker-nodes"
#       desired_capacity = var.desired-worker-node
#       max_capacity     = var.max-worker-node
#       min_capacity     = var.min-worker-node
#       disk_size        = var.disk-size
#       instance_types    = [var.instance_type]
#     }
#   }

#   workers_additional_policies = [aws_iam_policy.worker_policy.arn]
# }

# resource "aws_iam_policy" "worker_policy" {
#   name        = "node-workers-policy-${var.cluster-name}"
#   description = "Node Workers IAM policies"

#   policy = file("${path.module}/iam-policy.json")
# }
