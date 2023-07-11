#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: installs strimzi operator for kafka.
# see: https://artifacthub.io/packages/helm/strimzi/strimzi-kafka-operator
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
locals {
  kafka_namespace = "kafka"
  tags = {}
}

data "template_file" "kafka-values" {
  template = file("${path.module}/yml/kafka-values.yaml")
}

data "template_file" "kafka" {
  template = file("${path.module}/yml/kafka.yaml")
  vars = {
    name = var.shared_resource_name
  }
}


resource "helm_release" "strimzi" {
  namespace        = local.kafka_namespace
  create_namespace = true

  name       = "strimzi"
  repository = "https://strimzi.io/charts/"
  chart      = "strimzi-kafka-operator"
  version    = "~> 0.35"

  values = [
    data.template_file.kafka-values.rendered
  ]

}

resource "kubectl_manifest" "kafka" {
  yaml_body  = data.template_file.kafka.rendered
  depends_on = [helm_release.strimzi]
}