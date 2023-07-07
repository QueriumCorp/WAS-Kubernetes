# need this bc the default aws profile specifies us-east-2
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

data "aws_partition" "current" {}

data "aws_eks_cluster" "eks" {
  name = var.shared_resource_name
}

data "aws_eks_cluster_auth" "eks" {
  name = var.shared_resource_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks.token
}
