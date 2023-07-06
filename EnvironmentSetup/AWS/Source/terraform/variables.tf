variable "account_id" {
  default = "320713933456"
}
variable "aws_region" {
  default = "us-east-1"
}

variable "cluster-name" {
  default = "wolfram"
}

variable "cluster-version" {
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
