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
  minio_namespace        = "minio"
  minio_account_name     = "minio-admin"
  minio_ingress_hostname = "${local.minio_namespace}.${var.services_subdomain}"

  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source"    = "openedx_devops/terraform/stacks/modules/kubernetes_minio"
      "cookiecutter/resource/source"  = "charts.bitnami.com/bitnami/minio"
      "cookiecutter/resource/version" = "12.2"
    }
  )
}


data "template_file" "minio-values" {
  template = file("${path.module}/yml/minio-values.yaml")
}

resource "helm_release" "minio" {
  namespace        = local.minio_namespace
  create_namespace = false

  name       = "minio"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "minio"
  version    = "~> 12.2"

  # see https://docs.bitnami.com/kubernetes/infrastructure/minio/configuration/expose-service/
  set {
    name  = "ingress.enabled"
    value = false
  }

  depends_on = [
    kubernetes_namespace.minio
  ]
}

#------------------------------------------------------------------------------
#                               OTHER RESOURCES
#------------------------------------------------------------------------------
resource "kubectl_manifest" "hpa-autoscaler-minio" {
  yaml_body = file("${path.module}/yml/hpa-autoscaler-minio.yaml")
  depends_on = [ module.eks ]
}