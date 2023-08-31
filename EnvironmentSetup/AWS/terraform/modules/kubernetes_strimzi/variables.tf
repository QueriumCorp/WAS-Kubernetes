#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: jul-2023
#
# usage: create an EKS cluster
#------------------------------------------------------------------------------

variable "name" {
  type    = string
  default = "was"
}
variable "service_nodegroup" {
  description = "identifies the service managed node group, toleration, affinity"
  type        = string
}
