data "template_file" "was-ingress" {
  template = file("${path.module}/yml/ingress/was-ingress.yaml.tpl")
  vars = {
    namespace = var.namespace
    domain    = var.domain
  }
}

resource "kubectl_manifest" "was-ingress" {
  yaml_body = data.template_file.was-ingress.rendered
}
