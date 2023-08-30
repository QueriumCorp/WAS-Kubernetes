variable "root_domain" {
  type = string
}
variable "domain" {
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

variable "shared_resource_name" {
  default = "was"
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
  default = 100
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

variable "azs" {
  type    = list(string)
  default = ["us-easta", "us-eastb", "us-eastc"]
}
variable "private_subnets" {
  description = "The CIDR's of the three internal subnetworks that Terraform with automatically create for you."
  type        = list(string)
}
variable "public_subnets" {
  description = "the CIDRs of the three public subnets that Terraform will automatically create for you."
  type        = list(string)
}


variable "cidr" {
  type    = string
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default     = {}
}
