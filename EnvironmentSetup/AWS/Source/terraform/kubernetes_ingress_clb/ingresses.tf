resource "kubectl_manifest" "was-ingress-awes-service" {
  yaml_body = file("${path.module}/yml/was-ingress-awes-service.yml")
  depends_on = [ helm_release.ingress_nginx_controller ]
}
resource "kubectl_manifest" "was-ingress-endpoint-manager-service" {
  yaml_body = file("${path.module}/yml/was-ingress-endpoint-manager-service.yml")
  depends_on = [ helm_release.ingress_nginx_controller ]
}
resource "kubectl_manifest" "was-ingress-nodefiles-service" {
  yaml_body = file("${path.module}/yml/was-ingress-nodefiles-service.yml")
  depends_on = [ helm_release.ingress_nginx_controller ]
}
resource "kubectl_manifest" "was-ingress-resources-manager-service" {
  yaml_body = file("${path.module}/yml/was-ingress-resources-manager-service.yml")
  depends_on = [ helm_release.ingress_nginx_controller ]
}
