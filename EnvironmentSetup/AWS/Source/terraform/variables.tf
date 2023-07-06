variable "account_id" {
  default = "01234567891"
}
variable "aws_region" {
  # mcdaniel: currently only works in us-east-1
  # have yet to invetigate why.
  default = "us-east-1"
}

variable "cidr" {
  type = string
  default = "10.168.0.0/16"
}

variable "private_subnets" {
  type = list(string)
  default = ["10.168.128.0/18", "10.168.192.0/18"]
}
variable "public_subnets" {
  type = list(string)
  default = ["10.168.0.0/18", "10.168.64.0/18"]  
}

variable "cluster_name" {
  default = "WAS"
}

variable "cluster_version" {
  default = "1.27"
}

variable "disk-size" {
  default = "30"
}

variable "instance_types" {
  type = list(string)
  default = ["c5.2xlarge", "t3.2xlarge", "c5d.2xlarge", "t3a.2xlarge", "t2.2xlarge"]
}

variable "desired-worker-node" {
  default = "2"
}

variable "min-worker-node" {
  default = "2"
}

variable "max-worker-node" {
  default = "10"
}

variable "capacity_type" {
  default = "ON_DEMAND"
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