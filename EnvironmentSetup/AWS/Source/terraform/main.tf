locals {
  cluster_name    = var.cluster_name
  aws_region      = var.aws_region
  account_id      = var.account_id
}

provider "aws" {
  region = "us-east-1"
}
terraform {
  backend "s3" {
    bucket         = "320713933456-terraform-tfstate-was-01"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking-was"
    profile        = "default" 
    encrypt        = false
  }
}


