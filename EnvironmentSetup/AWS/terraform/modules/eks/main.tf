#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: jul-2023
#
# usage: create an EKS cluster
#------------------------------------------------------------------------------
locals {
  timestamp = "${timestamp()}"
  timestamp_sanitized = formatdate("YYYYMMDDhhmm", local.timestamp)
}

data "aws_availability_zones" "available" {
}

data "aws_route53_zone" "root_domain" {
  name = var.root_domain
}

resource "aws_route53_zone" "subdomain" {
  name = var.domain
}
resource "aws_route53_record" "subdomain-ns" {
  zone_id = data.aws_route53_zone.root_domain.zone_id
  name    = aws_route53_zone.subdomain.name
  type    = "NS"
  ttl     = "600"
  records = aws_route53_zone.subdomain.name_servers
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name                 = var.shared_resource_name
  cidr                 = var.cidr
  azs                  = var.azs

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

  tags = var.tags
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.16"

  cluster_name                    = var.shared_resource_name
  cluster_version                 = var.cluster_version
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = [module.vpc.private_subnets[0]]
  control_plane_subnet_ids        = module.vpc.private_subnets
  create_cloudwatch_log_group     = false
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa                     = true
  tags                            = var.tags

  create_kms_key            = true
  kms_key_description       = "Kubernetes key for Wolfram Application Server"
  kms_key_aliases           = ["eks/was-2023082919"]
  manage_aws_auth_configmap = true
  aws_auth_users            = var.aws_auth_users
  kms_key_owners            = var.kms_key_owners


  cluster_addons = {
    vpc-cni = {
      most_recent          = true
      before_compute       = true
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          # also see: https://medium.com/nerd-for-tech/eks-networking-cni-457ae298b9e6
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
          WARM_ENI_TARGET          = "0"
          WARM_IP_TARGET           = "2"
        }
      })
    }
    coredns    = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
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
      cidr_blocks = ["10.0.0.0/16"]
    }
    port_8443 = {
      description                = "open port 8443 to vpc"
      protocol                   = "-1"
      from_port                  = 8443
      to_port                    = 8443
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
      desired_size      = var.desired_worker_node
      max_size          = var.max_worker_node
      min_size          = var.min_worker_node
      instance_types    = var.instance_types
      availability_zones = var.azs[0]

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_type           = "gp3"
            volume_size           = var.disk_size
            delete_on_termination = true
          }
        }
      }
      tags = merge(
        var.tags,
        # Tag node group resources for Karpenter auto-discovery
        # NOTE - if creating multiple security groups with this module, only tag the
        # security group that Karpenter should utilize with the following tag
        { Name = "eks-${var.shared_resource_name}" },
        # Tag node group resources for Karpenter auto-discovery
        # NOTE - if creating multiple security groups with this module, only tag the
        # security group that Karpenter should utilize with the following tag
        { 
          "karpenter.sh/discovery" = var.namespace
        },
      )


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

resource "kubernetes_namespace" "was" {
  metadata {
    name = var.namespace
  }

  depends_on = [module.eks]
}

data "template_file" "gp3" {
  template = file("${path.module}/yml/gp3.yaml")
}

resource "kubectl_manifest" "gp3" {
  yaml_body = data.template_file.gp3.rendered

  depends_on = [module.eks]
}
