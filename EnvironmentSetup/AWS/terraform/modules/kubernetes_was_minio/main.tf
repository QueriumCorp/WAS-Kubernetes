#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: jul-2023
#
# usage: installs wolframapplicationserver/minio
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
  minio_account_name = "minio-admin"
}


resource "random_password" "minio_admin" {
  length  = 16
  special = false
  keepers = {
    version = "1"
  }
}
