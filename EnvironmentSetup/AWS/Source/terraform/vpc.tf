module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "~> 5.0.0"
  name                   = "${local.cluster_name}-vpc"
  cidr                   = "10.168.0.0/16"
  azs                    = data.aws_availability_zones.available.names
  private_subnets        = ["10.168.128.0/18", "10.168.192.0/18"]
  public_subnets         = ["10.168.0.0/18", "10.168.64.0/18"]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_dns_hostnames   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
  
  tags = {
    Terraform = "true"
    Environment = "${local.cluster_name}"
  }

}

