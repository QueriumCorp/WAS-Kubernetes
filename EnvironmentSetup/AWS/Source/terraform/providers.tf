provider "aws" {
  region = "us-east-1"
  profile = "default"
}

data "aws_partition" "current" {}

data "aws_eks_cluster" "eks" {
  name = var.cluster_name
  depends_on = [ module.eks ]
}

data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_name
  depends_on = [ module.eks ]
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
