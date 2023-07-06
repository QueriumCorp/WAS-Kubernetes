resource "kubectl_manifest" "hpa-autoscaler-active-web-elements-server" {
  yaml_body = file("${path.module}/yml/hpa-autoscaler-active-web-elements-server.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "hpa-autoscaler-endpoint-manager" {
  yaml_body = file("${path.module}/yml/hpa-autoscaler-endpoint-manager.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "hpa-autoscaler-resource-manager" {
  yaml_body = file("${path.module}/yml/hpa-autoscaler-resource-manager.yaml")
  depends_on = [ module.eks ]
}
