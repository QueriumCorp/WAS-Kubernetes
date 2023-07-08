terraform {
  backend "azurerm" {
    resource_group_name  = "XXXXXX"
    storage_account_name = "YYYYYY"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.13"
    }
  }
  required_version = "~> 1.3"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "${var.cluster_name}-rg"
  location = var.aks_region

  tags = {
    environment = "Wolfram Application Server"
  }
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "${var.cluster_name}-aks"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${var.cluster_name}-k8s"
  kubernetes_version  = var.cluster_version

  default_node_pool {
    name                = "workernodes"
    node_count          = var.desired_worker_node
    vm_size             = var.instance_type
    os_disk_size_gb     = var.disk_size
    max_pods            = var.max_pods
    enable_auto_scaling = true
    min_count           = var.min_worker_node
    max_count           = var.max_worker_node
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  tags = {
    environment = "Wolfram Application Server"
  }

}
