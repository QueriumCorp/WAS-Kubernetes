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

data "template_file" "kafka" {
  template = file("${path.module}/yml/kafka.yaml.tpl")
  vars = {
    name            = var.name
    kafka_namespace = local.kafka_namespace
  }
}

data "template_file" "kafka-bridge" {
  template = file("${path.module}/yml/kafka-bridge.yaml.tpl")
  vars = {
    name            = var.name
    kafka_namespace = local.kafka_namespace
  }
}

###############################################################################
#                               Resources
###############################################################################
resource "kubectl_manifest" "kafka" {
  yaml_body          = data.template_file.kafka.rendered
  override_namespace = local.kafka_namespace
}


resource "kubectl_manifest" "kafka-bridge" {
  yaml_body = data.template_file.kafka-bridge.rendered

}
