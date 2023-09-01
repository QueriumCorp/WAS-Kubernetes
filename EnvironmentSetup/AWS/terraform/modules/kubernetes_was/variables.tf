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

variable "cluster_issuer" {
  type = string
}

variable "private_subnet" {
  type = string  
}

variable "s3_bucket" {
  type = string
}

# WAS
variable "was_active_web_elements_server_version" {
  # see https://hub.docker.com/r/wolframapplicationserver/active-web-elements-server/tags
  type    = string
  default = "3.1.5"
}
variable "was_endpoint_manager_version" {
  # see https://hub.docker.com/r/wolframapplicationserver/endpoint-manager/tags
  type    = string
  default = "1.2.1"
}
variable "was_resource_manager_version" {
  # see https://hub.docker.com/r/wolframapplicationserver/resource-manager/tags
  type    = string
  default = "1.2.1"
}
