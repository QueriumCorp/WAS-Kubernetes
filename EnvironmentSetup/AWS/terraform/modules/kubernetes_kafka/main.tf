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
