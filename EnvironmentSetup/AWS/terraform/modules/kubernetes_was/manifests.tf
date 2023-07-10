
data "template_file" "service-resource-manager" {
  template = file("${path.module}/yml/service-resource-manager.yaml.tpl")
  vars = {
    namespace = var.namespace
  }
}


data "template_file" "deployment-resource-manager" {
  template = file("${path.module}/yml/deployment-resource-manager.yaml.tpl")
  vars = {
    namespace               = var.namespace
    response                = ""
    minio_access_key        = "set-me-please"
    minio_secret_key        = ""
    resource_info_bucket    = ""
    nodefiles_bucket        = ""
    resource_bucket_region  = ""
    nodefiles_bucket_region = ""
  }
}

data "template_file" "hpa-autoscaler-active-web-elements-server" {
  template = file("${path.module}/yml/hpa-autoscaler-active-web-elements-server.yaml.tpl")
  vars = {
    namespace = var.namespace
  }
}

data "template_file" "hpa-autoscaler-endpoint-manager" {
  template = file("${path.module}/yml/hpa-autoscaler-endpoint-manager.yaml.tpl")
  vars = {
    namespace = var.namespace
  }
}

#------------------------------------------------------------------------------
#                             services
#------------------------------------------------------------------------------
resource "kubectl_manifest" "service-active-web-elements-server" {
  yaml_body = file("${path.module}/yml/service-active-web-elements-server.yaml")
}

resource "kubectl_manifest" "service-endpoint-manager" {
  yaml_body = file("${path.module}/yml/service-endpoint-manager.yaml")
}

resource "kubectl_manifest" "service-resource-manager" {
  yaml_body = data.template_file.service-resource-manager.rendered
}

#------------------------------------------------------------------------------
#                             deployments
#------------------------------------------------------------------------------

resource "kubectl_manifest" "deployment-active-web-elements-server" {
  yaml_body  = file("${path.module}/yml/deployment-active-web-elements-server.yaml")
  depends_on = [kubectl_manifest.service-active-web-elements-server]
}
resource "kubectl_manifest" "deployment-endpoint-manager" {
  yaml_body  = file("${path.module}/yml/deployment-endpoint-manager.yaml")
  depends_on = [kubectl_manifest.service-endpoint-manager]
}

resource "kubectl_manifest" "deployment-resource-manager" {
  yaml_body  = data.template_file.deployment-resource-manager.rendered
  depends_on = [kubectl_manifest.service-endpoint-manager]
}

#------------------------------------------------------------------------------
#                             hpa
#------------------------------------------------------------------------------
resource "kubectl_manifest" "hpa-autoscaler-active-web-elements-server" {
  yaml_body  = data.template_file.hpa-autoscaler-active-web-elements-server.rendered
}
resource "kubectl_manifest" "hpa-autoscaler-endpoint-manager" {
  yaml_body  = data.template_file.hpa-autoscaler-endpoint-manager.rendered
}
