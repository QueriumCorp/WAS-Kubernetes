# -----------------------------------------------------------------------------
# Querium custom configuration
# -----------------------------------------------------------------------------

# client identifying information
# -------------------------------------
account_id            = "320713933456"
aws_region            = "us-east-1"
aws_profile           = "default"
shared_resource_name  = "was2"
stack_namespace       = "was2"
namespace             = "was2"
root_domain           = "stepwisemath.ai"
services_subdomain    = "live.stepwisemath.ai"


# VPC
# -------------------------------------
cidr            = "10.168.0.0/16"
private_subnets = ["10.168.128.0/18", "10.168.192.0/18"]
public_subnets  = ["10.168.0.0/18", "10.168.64.0/18"]

# EKS
# -------------------------------------
cluster_version      = "1.27"
capacity_type        = "SPOT"
aws_auth_users = [
  # cluster will irreparably break if you remove the bastion IAM user
  # -------------------------------------------------------------------------
  {
    userarn  = "arn:aws:iam::320713933456:user/system/bastion-user/stepwisemath-global-live-bastion"
    username = "stepwisemath-global-live-bastion"
    groups   = ["system:masters"]
  },
  # -------------------------------------------------------------------------

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
  # cluster will irreparably break if you remove the bastion IAM user
  # -------------------------------------------------------------------------
  "arn:aws:iam::320713933456:user/system/bastion-user/stepwisemath-global-live-bastion",
  # -------------------------------------------------------------------------
  "arn:aws:iam::320713933456:user/mcdaniel",
  "arn:aws:iam::320713933456:user/kent.fuka",
]

# EKS managed node settings
# ----------------------------------
desired_worker_node = 2
max_worker_node     = 10
min_worker_node     = 2
disk_size           = 30
instance_types      = ["c5.2xlarge", "t3.2xlarge", "c5d.2xlarge", "t3a.2xlarge", "t2.2xlarge"]