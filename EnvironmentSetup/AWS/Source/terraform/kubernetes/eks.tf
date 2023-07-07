
resource "aws_iam_policy" "worker_policy" {
  name        = "node-workers-policy-${var.cluster_name}"
  description = "Node Workers IAM policies"

  policy = file("${path.module}/node-workers-policy.json")
}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 19.4"
  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  subnet_ids                      = module.vpc.private_subnets
  vpc_id                          = module.vpc.vpc_id
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
    vpc-cni = {}
    coredns = {}
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
      name              = "${var.cluster_name}-worker-nodes"
      capacity_type     = var.capacity_type
      enable_monitoring = false
      desired_capacity  = var.desired_worker_node
      max_capacity      = var.max_worker_node
      min_capacity      = var.min_worker_node
      disk_size         = var.disk_size
      instance_types    = var.instance_types

      labels = {
        node-group = "was"
      }

    }
  }

  iam_role_additional_policies = {
    WorkersAdditionalPolicies = aws_iam_policy.worker_policy.arn
    AmazonEBSCSIDriverPolicy = data.aws_iam_policy.AmazonEBSCSIDriverPolicy.arn
  }

}

# force a refresh of local kubeconfig
resource "null_resource" "kubectl-init" {
  provisioner "local-exec" {
    command = "aws eks --region ${var.aws_region} update-kubeconfig --name ${var.cluster_name}"
  }
  depends_on = [module.eks.cluster_name]
}


resource "aws_security_group" "worker_group_mgmt" {
  name_prefix = "${var.cluster_name}-eks_hosting_group_mgmt"
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
  name_prefix = "${var.cluster_name}-eks_all_worker_management"
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
