data "aws_availability_zones" "available" {
}


module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"

  name                 = var.shared_resource_name
  cidr                 = var.cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_ipv6          = false
  enable_dns_support   = true

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.shared_resource_name}" = "owned"
    "karpenter.sh/discovery"                            = var.shared_resource_name
    "kubernetes.io/role/internal-elb"                   = "1"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.shared_resource_name}" = "shared"
    "kubernetes.io/role/elb"                            = "1"
  }

  tags = {
    Terraform   = "true"
    Environment = "${var.shared_resource_name}"
  }
}


module "eks" {
  source                          = "terraform-aws-modules/eks/aws"

  cluster_name                    = var.shared_resource_name
  cluster_version                 = var.cluster_version
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  create_cloudwatch_log_group     = false
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa                     = true

  tags = {
    Environment = "Wolfram Application Server"
  }

  create_kms_key            = true
  manage_aws_auth_configmap = true
  aws_auth_users            = var.aws_auth_users
  kms_key_owners            = var.kms_key_owners


  cluster_addons = {
    vpc-cni    = {}
    coredns    = {}
    kube-proxy = {}
    aws-ebs-csi-driver = {
      service_account_role_arn = aws_iam_role.AmazonEKS_EBS_CSI_DriverRoleWAS.arn
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "WAS: Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = var.private_subnets
    }

    # FIX NOTE: this is a sledge hammer approach to getting Kafka running
    #           we need to understand whether this has any unintended consequences.
    port_all = {
      description                = "WAS: open all ports vpc"
      protocol                   = "-1"
      from_port                  = 0
      to_port                    = 0
      type                       = "ingress"
      source_node_security_group = true
    }

    port_8443 = {
      description                = "WAS: open port 8443 to vpc"
      protocol                   = "-1"
      from_port                  = 8443
      to_port                    = 8443
      type                       = "ingress"
      source_node_security_group = true
    }
    port_443 = {
      description                = "WAS: open port 443 to vpc"
      protocol                   = "-1"
      from_port                  = 443
      to_port                    = 443
      type                       = "ingress"
      source_node_security_group = true
    }
    egress_all = {
      description      = "WAS: Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_groups = {
    eks = {
      name              = "${var.shared_resource_name}-worker-nodes"
      capacity_type     = var.capacity_type
      enable_monitoring = false
      desired_capacity  = var.desired_worker_node
      max_capacity      = var.max_worker_node
      min_capacity      = var.min_worker_node
      disk_size         = var.disk_size
      instance_types    = var.instance_types

      labels = {
        node-group = var.namespace
      }

    }
  }

  iam_role_additional_policies = {
    WorkersAdditionalPolicies = aws_iam_policy.worker_policy.arn
    AmazonEBSCSIDriverPolicy  = data.aws_iam_policy.AmazonEBSCSIDriverPolicy.arn
  }

}

#------------------------------------------------------------------------------
#                             SUPPORTING RESOURCES
#------------------------------------------------------------------------------

resource "aws_iam_policy" "worker_policy" {
  name        = "node-workers-policy-${var.shared_resource_name}"
  description = "Node Workers IAM policies"

  policy = file("${path.module}/node-workers-policy.json")
}


# force a refresh of local kubeconfig
# resource "null_resource" "kubectl-init" {
#   provisioner "local-exec" {
#     command = "aws eks --region ${var.aws_region} update-kubeconfig --name ${var.shared_resource_name}"
#   }
#   depends_on = [ module.eks ]
# }


resource "aws_security_group" "worker_group_mgmt" {
  name_prefix = "${var.shared_resource_name}-eks_hosting_group_mgmt"
  description = "WAS: Ingress CLB worker group management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "WAS: Ingress CLB"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }

}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "${var.shared_resource_name}-eks_all_worker_management"
  description = "WAS: Ingress CLB worker management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "WAS: Ingress CLB"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}
