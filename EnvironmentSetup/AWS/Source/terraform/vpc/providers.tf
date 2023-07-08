# need this bc the default aws profile specifies us-east-2
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Required by Karpenter
data "aws_partition" "current" {}

