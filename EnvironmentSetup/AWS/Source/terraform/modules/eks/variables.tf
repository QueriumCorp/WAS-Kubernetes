variable "version" {
  type = string  
}
variable "account_id" {
  default = "01234567891"
  type    = string
}
variable "aws_region" {
  default = "us-east-1"
  type    = string
}

variable "aws_profile" {
  default = "default"
  type    = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "shared_resource_name" {
  default = "WAS"
  type    = string
}

variable "namespace" {
  default = "was"
  type    = string
}

variable "cluster_version" {
  default = "1.27"
  type    = string
}

variable "disk_size" {
  default = "30"
  type    = number
}

variable "instance_types" {
  type    = list(string)
  default = ["c5.2xlarge"]
}

variable "desired_worker_node" {
  default = "2"
  type    = number
}

variable "min_worker_node" {
  default = "2"
  type    = number
}

variable "max_worker_node" {
  default = "10"
  type    = number
}

variable "capacity_type" {
  default = "ON_DEMAND"
  type    = string
}

variable "aws_auth_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "kms_key_owners" {
  type    = list(any)
  default = []
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.168.128.0/18", "10.168.192.0/18"]
}
variable "public_subnets" {
  type    = list(string)
  default = ["10.168.0.0/18", "10.168.64.0/18"]
}

