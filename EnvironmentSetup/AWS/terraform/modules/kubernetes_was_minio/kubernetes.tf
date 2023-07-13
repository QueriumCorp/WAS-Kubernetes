#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: jul-2023
#
# usage:  create and store web app sign in token.
#         see:  https://minio.dev/docs/latest/tutorials/getting-started/
#
#         to retrieve this token
#         kubectl get --namespace minio secret minio-admin -o go-template='{{.data.token | base64decode}}'
#------------------------------------------------------------------------------

resource "kubernetes_service_account" "minio_admin" {
  metadata {
    name      = local.minio_account_name
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role_binding" "minio_admin" {
  metadata {
    name = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.minio_admin.metadata[0].name
    namespace = var.namespace
  }
  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [
    kubernetes_service_account.minio_admin,
  ]
}


resource "kubernetes_secret_v1" "minio_admin" {
  metadata {
    name      = local.minio_account_name
    namespace = var.namespace
    annotations = {
      "kubernetes.io/service-account.name"      = local.minio_account_name
      "kubernetes.io/service-account.namespace" = var.namespace
    }
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = false

  depends_on = [
    kubernetes_service_account.minio_admin,
  ]
}
