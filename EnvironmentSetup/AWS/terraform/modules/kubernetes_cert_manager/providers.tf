#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date:       jul-2023
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------

data "aws_eks_cluster" "eks" {
  name = var.namespace
}
