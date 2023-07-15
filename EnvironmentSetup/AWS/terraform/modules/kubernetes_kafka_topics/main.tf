#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date:       jul-2023
#
# usage: installs strimzi operator for kafka.
# see: https://artifacthub.io/packages/helm/strimzi/strimzi-kafka-operator
#
# requirements: Strimzi must be installed first.
#-----------------------------------------------------------
locals {
  kafka_namespace = "kafka"
}

data "template_file" "was-topic-endpoint-info" {
  template = file("${path.module}/yml/was-topic-endpoint-info.yaml.tpl")
  vars = {
    name            = var.name
    kafka_namespace = local.kafka_namespace
  }
}

data "template_file" "was-topic-nodefile-info" {
  template = file("${path.module}/yml/was-topic-nodefile-info.yaml.tpl")
  vars = {
    name            = var.name
    kafka_namespace = local.kafka_namespace
  }
}

data "template_file" "was-topic-resource-info" {
  template = file("${path.module}/yml/was-topic-resource-info.yaml.tpl")
  vars = {
    name            = var.name
    kafka_namespace = local.kafka_namespace
  }
}

resource "kubectl_manifest" "was-topic-endpoint-info" {
  yaml_body          = data.template_file.was-topic-endpoint-info.rendered
  override_namespace = local.kafka_namespace
}
resource "kubectl_manifest" "was-topic-nodefile-info" {
  yaml_body          = data.template_file.was-topic-nodefile-info.rendered
  override_namespace = local.kafka_namespace
}
resource "kubectl_manifest" "was-topic-resource-info" {
  yaml_body          = data.template_file.was-topic-resource-info.rendered
  override_namespace = local.kafka_namespace
}
