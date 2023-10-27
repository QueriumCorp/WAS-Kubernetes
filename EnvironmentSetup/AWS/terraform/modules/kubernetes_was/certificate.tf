data "template_file" "certificate" {
  template = file("${path.module}/yml/cert-manager/certificate.yml.tpl")
  vars = {
    cluster_issuer = var.cluster_issuer
    domain         = var.domain
    namespace      = var.namespace
  }
}

resource "kubernetes_manifest" "certificate" {
  manifest = yamldecode(data.template_file.certificate.rendered)
}
