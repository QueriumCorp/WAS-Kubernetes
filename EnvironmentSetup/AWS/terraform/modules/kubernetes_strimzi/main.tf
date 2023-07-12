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

data "template_file" "kafka" {
  template = file("${path.module}/yml/kafka.yaml.tpl")
  vars = {
    name = var.name
  }
}

data "template_file" "was-topics" {
  template = file("${path.module}/yml/was-topics.yaml.tpl")
  vars = {
    name = var.name
  }
}

data "template_file" "kafka-bridge" {
  template = file("${path.module}/yml/kafka-bridge.yaml.tpl")
  vars = {
    name = var.name
  }
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

resource "kubectl_manifest" "kafka" {
  yaml_body          = data.template_file.kafka.rendered
  override_namespace = local.kafka_namespace
  depends_on         = [helm_release.strimzi]
}


resource "kubectl_manifest" "was-topics" {
  yaml_body = data.template_file.was-topics.rendered

  depends_on = [helm_release.strimzi]
}

resource "kubectl_manifest" "kafka-bridge" {
  yaml_body = data.template_file.kafka-bridge.rendered

  depends_on = [helm_release.strimzi]
}
