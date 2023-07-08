#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------

data "aws_eks_cluster" "eks" {
  name = var.namespace
}

data "aws_eks_cluster" "cluster" {
  name = var.namespace
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.namespace
}
