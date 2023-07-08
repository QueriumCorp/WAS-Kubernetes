# WAS stack configuration

# -----------------------------------------------------------------------------
# Required inputs
# -----------------------------------------------------------------------------
account_id           = "320713933456"
aws_region           = "us-east-1"
aws_profile          = "default"
root_domain          = "stepwisemath.ai"
services_subdomain   = "live.stepwisemath.ai"
aws_auth_users = [
  # add all IAM users who reqiure access to kubectrl
  # and/or the AWS EKS Kubernetes console
  # -----------------------------------
  {
    userarn  = "arn:aws:iam::320713933456:user/system/bastion-user/stepwisemath-global-live-bastion"
    username = "stepwisemath-global-live-bastion"
    groups   = ["system:masters"]
  },
  # -----------------------------------
  
  {
    userarn  = "arn:aws:iam::320713933456:user/mcdaniel"
    username = "mcdaniel"
    groups   = ["system:masters"]
  },
  {
    userarn  = "arn:aws:iam::320713933456:user/kent.fuka"
    username = "kent.fuka"
    groups   = ["system:masters"]
  },
]

kms_key_owners = [
  # add all IAM users who reqiure access to kubectrl
  # and/or the AWS EKS Kubernetes console
  # -----------------------------------
    "arn:aws:iam::320713933456:user/system/bastion-user/stepwisemath-global-live-bastion",
  # -----------------------------------
  "arn:aws:iam::320713933456:user/mcdaniel",
  "arn:aws:iam::320713933456:user/kent.fuka",
]


# -----------------------------------------------------------------------------
# Optional inputs
# -----------------------------------------------------------------------------

# stack identifiers
# -------------------------------------
shared_resource_name = "was2"
stack_namespace      = "was2"
namespace            = "was2"

# VPC
# -------------------------------------
cidr            = "192.168.0.0/20"
private_subnets = ["192.168.4.0/24", "192.168.5.0/24"]
public_subnets  = ["192.168.1.0/24", "192.168.2.0/24"]

# EKS
# -------------------------------------
cluster_version = "1.27"
capacity_type   = "SPOT"
# EKS managed node settings
# ----------------------------------
desired_worker_node = 2
max_worker_node     = 10
min_worker_node     = 2
disk_size           = 30
instance_types      = ["c5.2xlarge", "t3.2xlarge", "c5d.2xlarge", "t3a.2xlarge", "t2.2xlarge"]