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
shared_resource_name = "was"
cluster_version = "1.27"
aws_auth_users = [
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
  "arn:aws:iam::320713933456:user/mcdaniel",
  "arn:aws:iam::320713933456:user/kent.fuka",
]
tags = {
  Terraform   = "true"
  Platform    = "Wolfram Application Server"
  Environment = "was"
}

azs = ["us-easta", "us-eastb", "us-eastc"]
private_subnets      = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
public_subnets       = ["10.0.48.0/20", "10.0.64.0/20", "10.0.80.0/20"]
cidr = "10.0.0.0/16"

# AWS EKS Kubernetes
# -------------------------------------

# valid choices: 'SPOT', 'ON_DEMAND'
capacity_type = "SPOT"

# see: 
# ------------------------------------
# brew tap aws/tap
# brew install ec2-instance-selector
# ec2-instance-selector --memory-min 32 --memory-max 32 --vcpus-min 8 --vcpus-max 8 --cpu-architecture x86_64 --region us-east-1 --max-results 100 -o table-wide
instance_types = ["t3.xlarge"]
# instance_types = [
#   "t3.2xlarge", 
#   "t3a.2xlarge", 
#   "t2.2xlarge",
#   "d3en.2xlarge",
#   "g4ad.2xlarge",
#   "g4dn.2xlarge",
#   "g5.2xlarge",
#   "h1.2xlarge",
#   "m4.2xlarge",
#   "m5.2xlarge",
#   "m5a.2xlarge",
#   "m5ad.2xlarge",
#   "m5d.2xlarge",
#   "m5dn.2xlarge",
#   "m5n.2xlarge",
#   "m5zn.2xlarge",
#   "m6a.2xlarge",
#   "m6i.2xlarge",
#   "m6id.2xlarge",
#   "m6idn.2xlarge",
#   "m6in.2xlarge",
#   "m7a.2xlarge",
#   "m7i-flex.2xlarge",
#   "m7i.2xlarge",
#   "trn1.2xlarge"
#   ]

disk_size           = 100
min_worker_node     = 2
desired_worker_node = 2
max_worker_node     = 5

# Minio
# -------------------------------------
tenantPoolsServers          = 4
tenantPoolsVolumesPerServer = 4
tenantPoolsSize             = "10Gi"
tenantPoolsStorageClassName = "gp3"

# Wolfram Application Server
# -------------------------------------

# for latest stable container versions see https://hub.docker.com/u/wolframapplicationserver
was_active_web_elements_server_version = "3.1.5"
was_endpoint_manager_version           = "1.2.1"
was_resource_manager_version           = "1.2.1"
