data "aws_partition" "current" {}

provider "aws" {
  region = "us-east-1"
  profile = "default"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster_name", module.eks.cluster_name, "--region", "us-east-1", "--profile", "default"]
  }
}

# Required by Karpenter and metrics-server
provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster_name", module.eks.cluster_name, "--region", "us-east-1", "--profile", "default"]
  }
}

# Required by Karpenter and metrics-server
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster_name", module.eks.cluster_name, "--region", "us-east-1", "--profile", "default"]
    }
  }
}
