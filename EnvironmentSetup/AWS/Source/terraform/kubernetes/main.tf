locals {
  cluster_name    = var.cluster_name
  aws_region      = var.aws_region
  account_id      = var.account_id
}

terraform {
  backend "s3" {
    bucket         = "320713933456-terraform-tfstate-was-01"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking-was2"
    profile        = "default" 
    encrypt        = false
  }
}

#------------------------------------------------------------------------------
#                        SUPPORTING RESOURCES
#------------------------------------------------------------------------------
data "aws_availability_zones" "available" {
}

data "aws_subnet" "private_subnet" {
  id = var.subnet_ids[random_integer.subnet_id.result]
}

# randomize the choice of subnet. Each of the
# possible subnets corresponds to the AWS availability
# zones in the data center. Most data center have three
# availability zones, but some like us-east-1 have more than
# three.
resource "random_integer" "subnet_id" {
  min = 0
  max = length(data.aws_availability_zones.available.names) - 1
}
