#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date:       jul-2023
#
# usage: installs strimzi operator for kafka.
# see: https://artifacthub.io/packages/helm/strimzi/strimzi-kafka-operator
#
# requirements: you must initialize a local helm repo in order to run
# this mdoule.
#
# Strimzi
#   brew install helm
#   helm repo add strimzi https://strimzi.io/charts/
#   helm repo update
#   helm search repo strimzi
#   helm show values strimzi/strimzi-kafka-operator
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#-----------------------------------------------------------
locals {
  kafka_namespace = "kafka"
}

data "template_file" "strimzi-values" {
  template = file("${path.module}/yml/strimzi-values.yaml")
}

###############################################################################
#                               Resources
###############################################################################
resource "kubernetes_namespace" "kafka" {
  metadata {
    name = local.kafka_namespace
  }
}

resource "helm_release" "strimzi" {
  namespace        = local.kafka_namespace
  create_namespace = false

  name       = "strimzi"
  repository = "https://strimzi.io/charts/"
  chart      = "strimzi-kafka-operator"
  version    = "~> 0.35"

  values = [
    data.template_file.strimzi-values.rendered
  ]
  depends_on = [kubernetes_namespace.kafka]
}
