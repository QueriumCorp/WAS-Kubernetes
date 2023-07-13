#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Jan-2023
#
# usage: installs minio
# see: https://minio.dev/docs/latest/tutorials/getting-started/
#
# requirements: you must initialize a local helm repo in order to run
# this mdoule.
#
#   brew install helm
#   helm repo add minio https://raw.githubusercontent.com/minio/operator/master/
#   helm repo update
#   helm search repo minio/operator
#   helm search repo minio/tenant
#   helm show values minio/operator
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#
# To generate the web app sign-in token:
#   kubectl get --namespace minio secret minio-admin -o go-template='{{.data.token | base64decode}}'
#-----------------------------------------------------------
locals {
  namespace = "minio"
}


data "template_file" "minio-values" {
  template = file("${path.module}/yml/minio-values.yaml")
}

resource "helm_release" "minio" {
  namespace        = local.namespace
  create_namespace = true

  name       = "minio"
  repository = "https://raw.githubusercontent.com/minio/operator/master/"
  chart      = "operator"
  version    = "~> 5.0"

  values = [
    data.template_file.minio-values.rendered
  ]

}
