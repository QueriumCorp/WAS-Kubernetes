# WAS stack configuration

# -----------------------------------------------------------------------------
# Required inputs
# -----------------------------------------------------------------------------
account_id         = "320713933456"
aws_region         = "us-east-1"
aws_profile        = "stepwise"
root_domain        = "stepwisemath.ai"
services_subdomain = "live.stepwisemath.ai"
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


# -----------------------------------------------------------------------------
# Override optional inputs here
# -----------------------------------------------------------------------------

shared_resource_name = "was2"

# valid choices: 'SPOT', 'ON_DEMAND'
capacity_type  = "SPOT"
instance_types = ["c5.2xlarge", "t3.2xlarge", "c5d.2xlarge", "t3a.2xlarge", "t2.2xlarge"]

min_worker_node     = 2
desired_worker_node = 2
max_worker_node     = 10
