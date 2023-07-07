variable "cluster_name" {
  default = "WAS"
}

variable "aks_region" {
  default = "eastus"
}

variable "desired_worker_node" {
  default = "2"
}

variable "min_worker_node" {
  default = "2"
}

variable "max_worker_node" {
  default = "10"
}

variable "max_pods" {
  default = "100"
}

variable "cluster_version" {
  default = "1.27"
}

variable "disk_size" {
  default = "30"
}

variable "instance_type" {
  default = "Standard_D8s_v3"
}

variable "appId" {
  default = "XXXXXX"
}

variable "password" {
  default = "YYYYYY"
}

