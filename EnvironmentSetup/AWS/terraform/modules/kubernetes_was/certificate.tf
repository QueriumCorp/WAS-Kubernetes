data "template_file" "certificate" {
  template = file("${path.module}/yml/cert-manager/certificate.yml.tpl")
  vars = {
    domain    = var.domain
    namespace = var.namespace
  }
}

resource "kubectl_manifest" "certificate" {
  yaml_body = data.template_file.certificate.rendered
}
