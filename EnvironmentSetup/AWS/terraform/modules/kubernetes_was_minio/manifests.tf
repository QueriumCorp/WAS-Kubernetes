data "template_file" "minio-service" {
  template = file("${path.module}/yml/minio-service.yaml.tpl")
  vars = {
    namespace = var.namespace
  }
}

data "template_file" "minio-deployment" {
  template = file("${path.module}/yml/minio-deployment.yaml.tpl")
  vars = {
    namespace        = var.namespace
    minio_access_key = "set-me-please"
    minio_secret_key = "set-me-please"
  }
}

data "template_file" "hpa-autoscaler-minio" {
  template = file("${path.module}/yml/hpa-autoscaler-minio.yaml.tpl")
  vars = {
    namespace = var.namespace
  }
}

resource "kubectl_manifest" "minio-service" {
  yaml_body = data.template_file.minio-service.rendered
}

resource "kubectl_manifest" "minio-deployment" {
  yaml_body = data.template_file.minio-deployment.rendered
}

resource "kubectl_manifest" "hpa-autoscaler-minio" {
  yaml_body = data.template_file.hpa-autoscaler-minio.rendered
}
