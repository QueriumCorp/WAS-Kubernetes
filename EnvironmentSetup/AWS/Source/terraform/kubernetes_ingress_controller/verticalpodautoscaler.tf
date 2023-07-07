
data "template_file" "vpa-nginx" {
  template = file("${path.module}/yml/vpa-nginx-controller.yaml")
}

resource "kubectl_manifest" "nginx" {
  yaml_body = data.template_file.vpa-nginx.rendered
}
