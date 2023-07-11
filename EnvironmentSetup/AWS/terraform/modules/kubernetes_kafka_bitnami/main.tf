#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: installs kafka service.
# see: https://artifacthub.io/packages/helm/bitnami/kafka
#
# requirements: you must initialize a local helm repo in order to run
# this mdoule.
#
#   brew install helm
#   helm repo add bitnami https://charts.bitnami.com/bitnami
#   helm repo update
#   helm search repo bitnami/kafka
#   helm show values bitnami/kafka

# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#-----------------------------------------------------------
# FIX NOTE: the policy lacks some permissions for creating/terminating instances
#  as well as pricing:GetProducts.
#
# FIXED. but see note below about version.
#
# see: https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-role-for-service-accounts-eks
locals {
  tags = {}
}

data "template_file" "kafka-values" {
  template = file("${path.module}/yml/kafka-values.yaml")
}


resource "helm_release" "kafka" {
  namespace        = var.namespace
  create_namespace = true

  name       = "kafka"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kafka"
  version    = "~> 23.0"

  set {
    name = "persistence.size"
    value = "8Gi"
  }

  set {
    name = "logPersistence.enabled"
    value = true
  }
  set {
    name = "logPersistence.size"
    value = "8Gi"
  }
  set {
    name = "volumePermissions.enabled"
    value = true
  }
  set {
    name = "persistence.enabled"
    value = true
  }
  set {
    name = "auth.clientProtocol"
    value = "plaintext"
  }
  set {
    name = "listeners"
    value = "PLAINTEXT://0.0.0.0:9092"
  }
  set {
    name = "advertisedListeners"
    value = "PLAINTEXT://0.0.0.0:9092"
  }

  values = [
    data.template_file.kafka-values.rendered
  ]

}

