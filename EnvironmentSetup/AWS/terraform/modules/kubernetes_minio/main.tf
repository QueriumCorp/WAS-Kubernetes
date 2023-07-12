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
#   helm repo add bitnami https://charts.bitnami.com/bitnami
#   helm repo update
#   helm search repo bitnami/minio
#   helm show values bitnami/minio
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#
# To generate the web app sign-in token:
#   kubectl get --namespace minio secret minio-admin -o go-template='{{.data.token | base64decode}}'
#-----------------------------------------------------------
locals {
  namespace              = "minio"
  minio_account_name     = "minio-admin"
  minio_ingress_hostname = var.ingress_hostname
}


data "template_file" "minio-values" {
  template = file("${path.module}/yml/minio-values.yaml")
}

resource "random_password" "minio_admin" {
  length  = 16
  special = false
  keepers = {
    version = "1"
  }
}

resource "helm_release" "minio" {
  namespace        = local.namespace
  create_namespace = false

  name       = "minio"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "minio"
  version    = "~> 12.6"

  # see https://docs.bitnami.com/kubernetes/infrastructure/minio/configuration/expose-service/
  set {
    name  = "ingress.enabled"
    value = false
  }

  values = [
    data.template_file.minio-values.rendered
  ]

  depends_on = [
    kubernetes_namespace.minio
  ]
}

