variable "account_id" {
  default = "320713933456"
}
variable "cookiecutter_common_resource_name" {
  defaults = "stepwisemath-global-live"
} 
variable "aws_region" {
  #default = "us-east-1"
  default = "us-east-2"
}

variable "cluster-name" {
  #default = "WAS"
  default = "stepwisemath-global-live"
}

variable "cluster-version" {
  #default = "1.24"
  default = "1.25"
}

variable "disk-size" {
  default = "30"
}

variable "instance_type" {
  default = "c5.2xlarge"
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
