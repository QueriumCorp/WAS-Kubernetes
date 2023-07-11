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
# Strimzi
#   brew install helm
#   helm repo add strimzi https://strimzi.io/charts/
#   helm repo update
#   helm search repo strimzi
#   helm show values strimzi
#
# Zookeeper
#   helm repo add bitnami https://charts.bitnami.com/bitnami
#   helm repo update
#   helm search repo bitnami/zookeeper
#   helm show values bitnami/zookeeper

# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#-----------------------------------------------------------
locals {
  kafka_namespace = "kafka"
  tags = {}
}

data "template_file" "zookeeper-values" {
  template = file("${path.module}/yml/zookeeper-values.yaml")
}

data "template_file" "strimzi-values" {
  template = file("${path.module}/yml/strimzi-values.yaml")
}

data "template_file" "kafka" {
  template = file("${path.module}/yml/kafka-persistent.yaml.tpl")
  vars = {
    name            = var.name
  }
}

resource "helm_release" "zookeeper" {
  namespace        = local.kafka_namespace
  create_namespace = true

  name       = "zookeeper"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "zookeeper"
  version    = "~> 11.4"

  values = [
    data.template_file.zookeeper-values.rendered
  ]

}
resource "helm_release" "strimzi" {
  namespace        = local.kafka_namespace
  create_namespace = true

  name       = "strimzi"
  repository = "https://strimzi.io/charts/"
  chart      = "strimzi-kafka-operator"
  version    = "~> 0.35"

  values = [
    data.template_file.strimzi-values.rendered
  ]

}

resource "kubectl_manifest" "kafka" {
  yaml_body  = data.template_file.kafka.rendered
  override_namespace  = local.kafka_namespace
  depends_on = [helm_release.strimzi]
}
