#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date:       jul-2023
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------

variable "shared_resource_name" {
  type = string
}

variable "namespace" {
  type    = string
  default = "was"
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  type = string
}

variable "domain" {
  type = string
}

variable "s3_bucket" {
  type = string
}
