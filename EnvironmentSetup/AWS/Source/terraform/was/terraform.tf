#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date:       July-2023
#
# usage:      Terraform configuration
#------------------------------------------------------------------------------

terraform {
  required_version = "~> 1.3"
  backend "s3" {
    bucket         = "320713933456-terraform-tfstate-was-01"
    key            = "was/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking-was2"
    profile        = "default"
    encrypt        = false
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
    }
    helm = {
      source  = "hashicorp/helm"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
  }
}