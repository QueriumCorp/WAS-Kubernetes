data "kubernetes_secret" "minio-admin" {
  metadata {
    name      = "minio-admin"
    namespace = "minio"
  }
}


data "template_file" "service-resource-manager" {
  template = file("${path.module}/yml/service/service-resource-manager.yaml.tpl")
  vars = {
    namespace = var.namespace
  }
}

data "template_file" "service-active-web-elements-server" {
  template = file("${path.module}/yml/service/service-active-web-elements-server.yaml.tpl")
  vars = {
    namespace = var.namespace
  }
}

data "template_file" "service-endpoint-manager" {
  template = file("${path.module}/yml/service/service-endpoint-manager.yaml.tpl")
  vars = {
    namespace = var.namespace
  }
}


data "template_file" "deployment-active-web-elements-server" {
  template = file("${path.module}/yml/deployment/deployment-active-web-elements-server.yaml.tpl")
  vars = {
    namespace = var.namespace
    domain    = var.domain
  }
}
data "template_file" "deployment-endpoint-manager" {
  template = file("${path.module}/yml/deployment/deployment-endpoint-manager.yaml.tpl")
  vars = {
    namespace = var.namespace
    response  = ""
  }
}


data "template_file" "deployment-resource-manager" {
  template = file("${path.module}/yml/deployment/deployment-resource-manager.yaml.tpl")
  vars = {
    namespace               = var.namespace
    response                = ""
    minio_access_key        = base64decode(data.kubernetes_secret.minio-admin.data["ADMIN_USER"])
    minio_secret_key        = base64decode(data.kubernetes_secret.minio-admin.data["ADMIN_PASSWORD"])
    resource_info_bucket    = var.s3_bucket
    nodefiles_bucket        = var.s3_bucket
    resource_bucket_region  = var.aws_region
    nodefiles_bucket_region = var.aws_region
  }
}

data "template_file" "hpa-autoscaler-active-web-elements-server" {
  template = file("${path.module}/yml/hpa/hpa-autoscaler-active-web-elements-server.yaml.tpl")
  vars = {
    namespace = var.namespace
  }
}

data "template_file" "hpa-autoscaler-endpoint-manager" {
  template = file("${path.module}/yml/hpa/hpa-autoscaler-endpoint-manager.yaml.tpl")
  vars = {
    namespace = var.namespace
  }
}

#------------------------------------------------------------------------------
#                             services
#------------------------------------------------------------------------------
resource "kubectl_manifest" "service-active-web-elements-server" {
  yaml_body = data.template_file.service-active-web-elements-server.rendered
}

resource "kubectl_manifest" "service-endpoint-manager" {
  yaml_body = data.template_file.service-endpoint-manager.rendered
}

resource "kubectl_manifest" "service-resource-manager" {
  yaml_body = data.template_file.service-resource-manager.rendered
}

#------------------------------------------------------------------------------
#                             deployments
#------------------------------------------------------------------------------

resource "kubectl_manifest" "deployment-active-web-elements-server" {
  yaml_body  = data.template_file.deployment-active-web-elements-server.rendered
  depends_on = [kubectl_manifest.service-active-web-elements-server]
}
resource "kubectl_manifest" "deployment-endpoint-manager" {
  yaml_body  = data.template_file.deployment-endpoint-manager.rendered
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
