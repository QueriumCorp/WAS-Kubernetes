data "template_file" "active-web-elements-server-service" {
  template = file("${path.module}/yml/active-web-elements-server-service.yaml")
  vars = {}
}

data "template_file" "endpoint-manager-service" {
  template = file("${path.module}/yml/endpoint-manager-service.yaml")
  vars = {}
}

data "template_file" "resource-manager-service" {
  template = file("${path.module}/yml/resource-manager-service.yaml")
  vars = {}
}

resource "kubectl_manifest" "active-web-elements-server-service" {
  yaml_body = data.template_file.active-web-elements-server-service.rendered
  depends_on = [ module.eks ]
}

resource "kubectl_manifest" "endpoint-manager-service" {
  yaml_body = data.template_file.endpoint-manager-service.rendered
  depends_on = [ module.eks ]
}

resource "kubectl_manifest" "resource-manager-service" {
  yaml_body = data.template_file.resource-manager-service.rendered
  depends_on = [ module.eks ]
}



resource "kubectl_manifest" "deployment-active-web-elements-server" {
  yaml_body = file("${path.module}/yml/deployment-active-web-elements-server.yaml")
  depends_on = [ module.eks, kubectl_manifest.active-web-elements-server-service ]
}
resource "kubectl_manifest" "deployment-endpoint-manager" {
  yaml_body = file("${path.module}/yml/deployment-endpoint-manager.yaml")
  depends_on = [ module.eks, kubectl_manifest.endpoint-manager-service ]
}
resource "kubectl_manifest" "deployment-resource-manager" {
  yaml_body = file("${path.module}/yml/deployment-resource-manager.yaml")
  depends_on = [ module.eks, kubectl_manifest.resource-manager-service ]
}
