data "kubernetes_secret" "minio-admin" {
  metadata {
    name      = "minio-credentials"
    namespace = var.shared_resource_name
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
    namespace                              = var.namespace
    domain                                 = var.domain
    was_active_web_elements_server_version = var.was_active_web_elements_server_version
  }
}
data "template_file" "deployment-endpoint-manager" {
  template = file("${path.module}/yml/deployment/deployment-endpoint-manager.yaml.tpl")
  vars = {
    namespace                    = var.namespace
    response                     = ""
    was_endpoint_manager_version = var.was_endpoint_manager_version
  }
}


data "template_file" "deployment-resource-manager" {
  template = file("${path.module}/yml/deployment/deployment-resource-manager.yaml.tpl")
  vars = {
    was_resource_manager_version = var.was_resource_manager_version

    namespace               = var.namespace
    kafka_namespace         = "kafka"
    response                = ""
    minio_access_key        = data.kubernetes_secret.minio-admin.data["MINIO_USERNAME"]
    minio_secret_key        = data.kubernetes_secret.minio-admin.data["MINIO_PASSWORD"]
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
resource "kubernetes_manifest" "service-active-web-elements-server" {
  manifest = yamldecode(data.template_file.service-active-web-elements-server.rendered)
}

resource "kubernetes_manifest" "service-endpoint-manager" {
  manifest = yamldecode(data.template_file.service-endpoint-manager.rendered)
}

resource "kubernetes_manifest" "service-resource-manager" {
  manifest = yamldecode(data.template_file.service-resource-manager.rendered)
}

#------------------------------------------------------------------------------
#                             deployments
#------------------------------------------------------------------------------

# prerequisites to Active Web Elements Server
resource "kubernetes_manifest" "deployment-resource-manager" {
  manifest = yamldecode(data.template_file.deployment-resource-manager.rendered)
  depends_on = [
    kubernetes_manifest.service-resource-manager
  ]
}
resource "kubernetes_manifest" "deployment-endpoint-manager" {
  manifest = yamldecode(data.template_file.deployment-endpoint-manager.rendered)
  depends_on = [
    kubernetes_manifest.service-endpoint-manager
  ]
}

resource "kubernetes_manifest" "deployment-active-web-elements-server" {
  manifest = yamldecode(data.template_file.deployment-active-web-elements-server.rendered)
  depends_on = [
    kubernetes_manifest.service-active-web-elements-server,
    kubernetes_manifest.deployment-resource-manager,
    kubernetes_manifest.deployment-endpoint-manager
  ]
}


#------------------------------------------------------------------------------
#                             hpa
#------------------------------------------------------------------------------
resource "kubernetes_manifest" "hpa-autoscaler-active-web-elements-server" {
  manifest = yamldecode(data.template_file.hpa-autoscaler-active-web-elements-server.rendered)

  depends_on = [kubernetes_manifest.deployment-active-web-elements-server]
}
resource "kubernetes_manifest" "hpa-autoscaler-endpoint-manager" {
  manifest = yamldecode(data.template_file.hpa-autoscaler-endpoint-manager.rendered)

  depends_on = [kubernetes_manifest.deployment-endpoint-manager]
}
