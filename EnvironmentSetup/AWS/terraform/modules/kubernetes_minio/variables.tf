#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: jul-2023
#
# usage: create an EKS cluster
#------------------------------------------------------------------------------
variable "shared_resource_name" {
  type = string
}

variable "minio_host" {
  type = string
}

variable "tenantPoolsServers" {
  type    = number
  default = 4
}

variable "tenantPoolsVolumesPerServer" {
  type    = number
  default = 4
}

variable "tenantPoolsSize" {
  type    = string
  default = "10Gi"
}
variable "tenantPoolsStorageClassName" {
  type    = string
  default = "standard"
}
