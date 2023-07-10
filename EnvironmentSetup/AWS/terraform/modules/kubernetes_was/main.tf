locals {

  subnet_ids_list         = tolist(data.aws_subnets.was.ids)
  subnet_ids_random_index = random_id.index.dec % length(data.aws_subnets.was.ids)
  instance_subnet_id      = local.subnet_ids_list[local.subnet_ids_random_index]
}
#------------------------------------------------------------------------------
#                        SUPPORTING RESOURCES
#------------------------------------------------------------------------------
data "aws_vpc" "was" {
  filter {
    name   = "tag:Name"
    values = [var.namespace]
  }
}


data "aws_availability_zones" "available" {
}

data "aws_subnets" "was" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.was.id]
  }
}
data "aws_subnet" "private_subnet" {
  id = local.instance_subnet_id
}

resource "random_id" "index" {
  byte_length = 2
}
