#-----------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: install Kubecost https://www.kubecost.com/
#
# NOTE: you must initialize a local helm repo in order to run
# this script.
#
#   brew install helm
#   helm repo add cost-analyzer https://kubecost.github.io/cost-analyzer/
#   helm repo update
#   helm search repo cost-analyzer
#   helm show values cost-analyzer/cost-analyzer
#
#   Trouble shooting an installation:
#   helm ls --namespace kubecost
#   helm history cost-analyzer  --namespace kubecost
#   helm rollback cost-analyzer 4 --namespace kubecost

#-----------------------------------------------------------
locals {
  cost_analyzer = "cost-analyzer"
  kubecost      = "kubecost"
  tags = var.tags
}

data "template_file" "kubecost-values" {
  template = file("${path.module}/config/kubecost-values.yaml.tpl")
  vars = {
    # get a free Kubecost token here:
    # https://www.kubecost.com/install#show-instructions
    kubecostToken = "set-me-please"
    nodegroup     = var.service_nodegroup
  }
}

resource "helm_release" "kubecost" {
  name             = local.cost_analyzer
  namespace        = local.kubecost
  create_namespace = true

  repository = "https://kubecost.github.io/cost-analyzer/"
  chart      = "cost-analyzer"
  version    = "~> 1.100"

  values = [
    data.template_file.kubecost-values.rendered
  ]

}

