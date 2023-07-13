#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Jan-2023
#
# usage: installs minio
# see: https://min.io/docs/minio/kubernetes/upstream/operations/install-deploy-manage/deploy-operator-helm.html
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
#   helm show values minio/tenant
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#
# To generate the web app sign-in token:
#   $ SA_TOKEN=$(kubectl -n minio-operator  get secret console-sa-secret -o jsonpath="{.data.token}" | base64 --decode)
#   $ echo $SA_TOKEN
#-----------------------------------------------------------
locals {
  namespace = "minio-operator"
}


data "template_file" "minio-operator-values" {
  template = file("${path.module}/yml/minio-operator-values.yaml")
}

data "template_file" "minio-tenant-values" {
  template = file("${path.module}/yml/minio-tenant-values.yaml")
}

data "template_file" "minio-console-secret" {
  template = file("${path.module}/yml/minio-console-secret.yaml")

  vars = {
    minio_namespace = local.namespace
  }
}

resource "helm_release" "minio-operator" {
  namespace        = local.namespace
  create_namespace = true

  name       = "minio"
  repository = "https://raw.githubusercontent.com/minio/operator/master/"
  chart      = "operator"
  version    = "~> 5.0"

  values = [
    data.template_file.minio-operator-values.rendered
  ]

  set {
    name  = "console.ingress.enabled"
    value = true
  }
  set {
    name  = "console.ingress.host"
    value = var.minio_host
  }

}

resource "helm_release" "minio-tenant" {
  namespace        = var.namespace
  create_namespace = false

  name       = "minio"
  repository = "https://raw.githubusercontent.com/minio/operator/master/"
  chart      = "tenant"
  version    = "~> 5.0"

  values = [
    data.template_file.minio-tenant-values.rendered
  ]

}

resource "kubectl_manifest" "minio-console-secret" {
  yaml_body = data.template_file.minio-console-secret.rendered

  depends_on = [helm_release.minio-operator]
}
