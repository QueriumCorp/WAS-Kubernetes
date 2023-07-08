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

variable "cidr" {
  type    = string
  default = "10.168.0.0/16"
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.168.128.0/18", "10.168.192.0/18"]
}
variable "public_subnets" {
  type    = list(string)
  default = ["10.168.0.0/18", "10.168.64.0/18"]
}

variable "shared_resource_name" {
  default = "WAS"
  type    = string
}

