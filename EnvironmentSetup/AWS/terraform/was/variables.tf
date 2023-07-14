# vpc
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

variable "domain" {
  type = string
}

variable "cidr" {
  type    = string
  default = "192.168.0.0/20"
}

variable "private_subnets" {
  type    = list(string)
  default = ["192.168.4.0/24", "192.168.5.0/24"]
}
variable "public_subnets" {
  type    = list(string)
  default = ["192.168.1.0/24", "192.168.2.0/24"]
}

variable "shared_resource_name" {
  default = "was"
  type    = string
}


# eks
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

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default = {
    Terraform   = "true"
    Platform    = "Wolfram Application Server"
    Environment = "was"
  }
}

# Minio
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


# Wolfram Application Server
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
