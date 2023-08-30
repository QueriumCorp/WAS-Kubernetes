#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date:       July-2023
#
# usage:      Terraform configuration
#------------------------------------------------------------------------------

terraform {
  required_version = "~> 1.5"
  backend "s3" {
    bucket         = "320713933456-terraform-tfstate-was"
    key            = "was/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-was"
    profile        = "stepwise"
    encrypt        = false
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.22"
    }
  }
}
