# WAS stack configuration

###############################################################################
# Required inputs
###############################################################################
account_id  = "320713933456"
aws_region  = "us-east-1"
aws_profile = "stepwise"
domain      = "stepwisemath.ai"


###############################################################################
# Optional inputs
###############################################################################
shared_resource_name = "was2"
aws_auth_users = [
  {
    userarn  = "arn:aws:iam::320713933456:user/system/bastion-user/stepwisemath-global-live-bastion"
    username = "stepwisemath-global-live-bastion"
    groups   = ["system:masters"]
  },
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
  "arn:aws:iam::320713933456:user/system/bastion-user/stepwisemath-global-live-bastion",
  "arn:aws:iam::320713933456:user/mcdaniel",
  "arn:aws:iam::320713933456:user/kent.fuka",
]
tags = {
  Terraform   = "true"
  Platform    = "Wolfram Application Server"
  Environment = "was2"
}

# AWS EKS Kubernetes
# -------------------------------------

# valid choices: 'SPOT', 'ON_DEMAND'
capacity_type = "SPOT"
#instance_types = ["c5.2xlarge", "t3.2xlarge", "c5d.2xlarge", "t3a.2xlarge", "t2.2xlarge"]
instance_types = ["t3.2xlarge", "t3a.2xlarge", "t2.2xlarge"]

min_worker_node     = 2
desired_worker_node = 2
max_worker_node     = 10

# Minio
# -------------------------------------
tenantPoolsServers          = 4
tenantPoolsVolumesPerServer = 4
tenantPoolsSize             = "10Gi"
tenantPoolsStorageClassName = "gp2"

# Wolfram Application Server
# -------------------------------------

# for latest stable container versions see https://hub.docker.com/u/wolframapplicationserver
was_active_web_elements_server_version = "3.1.5"
was_endpoint_manager_version           = "1.2.1"
was_resource_manager_version           = "1.2.1"
