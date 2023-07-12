
data "template_file" "was-topics" {
  template = file("${path.module}/yml/was-topics.yaml")
  vars     = {}
}

resource "kubectl_manifest" "was-topics" {
  yaml_body = data.template_file.was-topics.rendered

  depends_on = [helm_release.strimzi]
}
