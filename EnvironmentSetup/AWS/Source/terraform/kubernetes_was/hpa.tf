resource "kubectl_manifest" "hpa-autoscaler-active-web-elements-server" {
  yaml_body = file("${path.module}/yml/hpa-autoscaler-active-web-elements-server.yaml")
  depends_on = [ kubernetes_namespace.was ]
}
resource "kubectl_manifest" "hpa-autoscaler-endpoint-manager" {
  yaml_body = file("${path.module}/yml/hpa-autoscaler-endpoint-manager.yaml")
  depends_on = [ kubernetes_namespace.was ]
}
