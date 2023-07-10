

data "template_file" "hpa-autoscaler-minio" {
  template = file("${path.module}/yml/hpa-autoscaler-minio.yaml.tpl")
  vars = {
    namespace = local.namespace
  }
}


resource "kubectl_manifest" "hpa-autoscaler-minio" {
  yaml_body = data.template_file.hpa-autoscaler-minio.rendered
}

