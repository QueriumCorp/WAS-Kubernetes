# -----------------------------------------------------------------------------
# Querium custom configuration
# -----------------------------------------------------------------------------
account_id          = "320713933456"
aws_region          = "us-east-1"
cluster_version     = "1.27"
cluster_name        = "wolfram"
capacity_type       = "SPOT"
aws_auth_users            = [
    {
        userarn  = "arn:aws:iam::${local.account_id}:user/mcdaniel"
        username = "mcdaniel"
        groups   = ["system:masters"]
    },
    {
        userarn  = "arn:aws:iam::${local.account_id}:user/kent.fuka"
        username = "kent.fuka"
        groups   = ["system:masters"]
    },
]

kms_key_owners = [
    "arn:aws:iam::${local.account_id}:user/mcdaniel",
    "arn:aws:iam::${local.account_id}:user/kent.fuka",
]
