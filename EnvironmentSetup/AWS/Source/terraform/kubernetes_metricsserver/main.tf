#------------------------------------------------------------------------------
#
# see: https://github.com/kubernetes-sigs/metrics-server
#
#------------------------------------------------------------------------------

#-----------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: installs Kubernetes metrics-server.
#
# NOTE: you must initialize a local helm repo in order to run
# this script.
#
#   brew install helm
#   helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
#   helm repo update
#   helm search repo metrics-server
#   helm show values metrics-server/metrics-server
#-----------------------------------------------------------
locals {
  metrics_server = "metrics-server"
  tags           = {}

}
data "template_file" "metrics-server-values" {
  template = file("${path.module}/config/metrics-server-values.yaml")
  vars     = {}
}

resource "helm_release" "metrics_server" {
  namespace        = local.metrics_server
  create_namespace = true

  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "~> 3.8"

  values = [
    data.template_file.metrics-server-values.rendered
  ]

}

