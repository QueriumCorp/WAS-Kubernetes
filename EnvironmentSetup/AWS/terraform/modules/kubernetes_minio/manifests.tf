# data "template_file" "deployment-resource-manager" {
#   template = file("${path.module}/yml/deployment-resource-manager.yaml.tpl")
#   vars = {
#     namespace               = local.namespace
#     response                = ""
#     minio_access_key        = "set-me-please"
#     minio_secret_key        = ""
#     resource_info_bucket    = ""
#     nodefiles_bucket        = ""
#     resource_bucket_region  = ""
#     nodefiles_bucket_region = ""
#   }
# }

data "template_file" "hpa-autoscaler-minio" {
  template = file("${path.module}/yml/hpa-autoscaler-minio.yaml.tpl")
  vars = {
    namespace = local.namespace
  }
}

data "template_file" "hpa-autoscaler-resource-manager" {
  template = file("${path.module}/yml/hpa-autoscaler-resource-manager.yaml.tpl")
  vars = {
    namespace = local.namespace
  }
}

data "template_file" "ingress-minio" {
  template = file("${path.module}/yml/ingress-minio.yaml.tpl")
  vars     = {}
}

data "template_file" "resource-manager-service" {
  template = file("${path.module}/yml/resource-manager-service.yaml.tpl")
  vars = {
    namespace = local.namespace
  }
}



# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

# resource "kubectl_manifest" "deployment-resource-manager" {
#   yaml_body = data.template_file.deployment-resource-manager.rendered
#   depends_on = [
#     kubectl_manifest.resource-manager-service
#   ]
# }

resource "kubectl_manifest" "hpa-autoscaler-minio" {
  yaml_body = data.template_file.hpa-autoscaler-minio.rendered
}

# resource "kubectl_manifest" "hpa-autoscaler-resource-manager" {
#   yaml_body  = data.template_file.hpa-autoscaler-resource-manager.rendered
# }


# resource "kubectl_manifest" "ingress-minio" {
#   yaml_body  = data.template_file.ingress-minio.rendered

#   depends_on = [
#     helm_release.minio,
#     kubernetes_namespace.minio
#   ]
# }

# resource "kubectl_manifest" "resource-manager-service" {
#   yaml_body  = data.template_file.resource-manager-service.rendered
# }


