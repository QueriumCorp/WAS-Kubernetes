#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: installs Kubernetes efs web application
# see: https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-efs/
#      https://blog.heptio.com/on-securing-the-kubernetes-efs-16b09b1b7aca
#
# to run:
#   in a separate terminal window run:  kubectl proxy
#   in a browser window run: http://localhost:8001/api/v1/namespaces/kubernetes-efs/services/https:kubernetes-efs:/proxy/
#
#   The login page will ask for a token. To generate said token, run:
#   kubectl -n kubernetes-efs create token kubernetes-efs
#
# helm repo add kubernetes-efs https://kubernetes.github.io/efs/
# helm install kubernetes-efs kubernetes-efs/kubernetes-efs
# helm search repo kubernetes-efs
# helm show values kubernetes-efs/kubernetes-efs
#
# Get the Kubernetes efs URL by running:
#   export POD_NAME=$(kubectl get pods -n default -l "app.kubernetes.io/name=kubernetes-efs,app.kubernetes.io/instance=kubernetes-efs" -o jsonpath="{.items[0].metadata.name}")
#   echo https://127.0.0.1:8443/
#   kubectl -n default port-forward $POD_NAME 8443:8443
#-----------------------------------------------------------
locals {
  tags = {}
}

data "template_file" "efs-values" {
  template = file("${path.module}/yml/values.yaml")
}

resource "helm_release" "efs" {
  name             = "common"
  namespace        = var.efs_namespace
  create_namespace = true

  chart      = "kubernetes-efs"
  repository = "https://kubernetes.github.io/efs/"
  version    = "~> 6.0"

  values = [
    data.template_file.efs-values.rendered
  ]
}

#------------------------------------------------------------------------------
#                               COOKIECUTTER META
#------------------------------------------------------------------------------
module "cookiecutter_meta" {
  source = "../../../../../../../common/cookiecutter_meta"
}

resource "kubernetes_secret" "cookiecutter" {
  metadata {
    name      = "cookiecutter-terraform"
    namespace = var.efs_namespace
  }

  # https://stackoverflow.com/questions/64134699/terraform-map-to-string-value
  data = {
    tags = jsonencode(local.tags)
  }
}
