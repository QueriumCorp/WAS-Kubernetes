data "template_file" "was-ingress-awes-service" {
  template = file("${path.module}/yml/was-ingress-awes-service.yml.tpl")
  vars = {
    namespace = var.namespace
  }
}
data "template_file" "was-ingress-endpoint-manager-service" {
  template = file("${path.module}/yml/was-ingress-endpoint-manager-service.yml.tpl")
  vars = {
    namespace = var.namespace
  }
}
data "template_file" "was-ingress-nodefiles-service" {
  template = file("${path.module}/yml/was-ingress-nodefiles-service.yml.tpl")
  vars = {
    namespace = var.namespace
  }
}
data "template_file" "was-ingress-resources-manager-service" {
  template = file("${path.module}/yml/was-ingress-resources-manager-service.yml.tpl")
  vars = {
    namespace = var.namespace
  }
}


resource "kubectl_manifest" "was-ingress-awes-service" {
  yaml_body  = data.template_file.was-ingress-awes-service.rendered
  depends_on = [helm_release.ingress_nginx_controller]
}
resource "kubectl_manifest" "was-ingress-endpoint-manager-service" {
  yaml_body  = data.template_file.was-ingress-endpoint-manager-service.rendered
  depends_on = [helm_release.ingress_nginx_controller]
}
resource "kubectl_manifest" "was-ingress-nodefiles-service" {
  yaml_body  = data.template_file.was-ingress-nodefiles-service.rendered
  depends_on = [helm_release.ingress_nginx_controller]
}
resource "kubectl_manifest" "was-ingress-resources-manager-service" {
  yaml_body  = data.template_file.was-ingress-resources-manager-service.rendered
  depends_on = [helm_release.ingress_nginx_controller]
}
