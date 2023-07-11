#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage:  installs strimzi operator for kafka.
# see:    https://strimzi.io/quickstarts/
#
#-----------------------------------------------------------
locals {
  kafka_namespace = "kafka"
}

data "http" "strimzi" {
  url = "https://strimzi.io/install/latest?namespace=kafka"
}

data "template_file" "strimzi" {
  template = file("${path.module}/yml/strimzi.yaml")
  vars = {
    name = var.name
  }
}
data "template_file" "kafka" {
  template = file("${path.module}/yml/kafka-persistent.yaml.tpl")
  vars = {
    name = var.name
  }
}
resource "kubernetes_namespace" "kafka" {
  metadata {
    name = local.kafka_namespace
  }
}

resource "kubectl_manifest" "strimzi" {
  yaml_body  = data.template_file.strimzi.rendered
  depends_on = [ kubernetes_namespace.kafka ]
}

resource "kubectl_manifest" "kafka" {
  yaml_body  = data.template_file.kafka.rendered
  depends_on = [kubectl_manifest.strimzi]
}
