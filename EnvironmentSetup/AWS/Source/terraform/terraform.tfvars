# -----------------------------------------------------------------------------
# Querium custom configuration
# -----------------------------------------------------------------------------
account_id          = "320713933456"
aws_region          = "us-east-1"
cluster_version     = "1.27"
cluster_name        = "was2"
capacity_type       = "SPOT"
aws_auth_users            = [
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
