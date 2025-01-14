#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date:       jul-2023
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------

variable "namespace" {
  type    = string
  default = "ingress-controller"
}
variable "domain" {
  type = string
}
variable "service_nodegroup" {
  description = "identifies the service managed node group, toleration, affinity"
  type        = string
}
