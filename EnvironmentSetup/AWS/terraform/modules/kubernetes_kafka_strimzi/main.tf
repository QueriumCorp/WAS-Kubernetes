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
#   helm repo add strimzi https://strimzi.io/charts/
#   helm repo update
#   helm search repo strimzi
#   helm show values strimzi

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
  repository = "https://strimzi.io/charts/"
  chart      = "kafka"
  version    = "~> 0.35"

  values = [
    data.template_file.kafka-values.rendered
  ]

}

