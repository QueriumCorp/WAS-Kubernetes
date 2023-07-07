

resource "kubectl_manifest" "active-web-elements-server-service" {
  yaml_body = file("${path.module}/yml/active-web-elements-server-service.yaml")
  depends_on = [
    kubernetes_namespace.was
  ]
}

resource "kubectl_manifest" "endpoint-manager-service" {
  yaml_body = file("${path.module}/yml/endpoint-manager-service.yaml")
  depends_on = [
    kubernetes_namespace.was
  ]
}


resource "kubectl_manifest" "deployment-active-web-elements-server" {
  yaml_body  = file("${path.module}/yml/deployment-active-web-elements-server.yaml")
  depends_on = [kubernetes_namespace.was, kubectl_manifest.active-web-elements-server-service]
}
resource "kubectl_manifest" "deployment-endpoint-manager" {
  yaml_body  = file("${path.module}/yml/deployment-endpoint-manager.yaml")
  depends_on = [kubernetes_namespace.was, kubectl_manifest.endpoint-manager-service]
}
