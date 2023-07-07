locals {
  shared_resource_name    = var.shared_resource_name
  aws_region      = var.aws_region
  account_id      = var.account_id

  subnet_ids_list         = tolist(data.aws_subnets.was.ids)
  subnet_ids_random_index = random_id.index.dec % length(data.aws_subnets.was.ids)
  instance_subnet_id      = local.subnet_ids_list[local.subnet_ids_random_index]
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

data aws_subnets "was" {
  filter {
    name   = "vpc-id"
    values = [ module.vpc.vpc_id ]
  }
}
data "aws_subnet" "private_subnet" {
  id = local.instance_subnet_id
}

resource random_id index {
  byte_length = 2
}
