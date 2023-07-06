variable "account_id" {
  default = "01234567891"
}
variable "aws_region" {
  # mcdaniel: currently only works in us-east-1
  # have yet to invetigate why.
  default = "us-east-1"
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
