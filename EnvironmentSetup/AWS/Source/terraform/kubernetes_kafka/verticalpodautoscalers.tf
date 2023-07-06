
data "template_file" "kafka" {
  template = file("${path.module}/yml/vpa-kafka.yaml")
}

resource "kubectl_manifest" "kafka" {
  yaml_body = data.template_file.kafka.rendered

  depends_on = [
    helm_release.kafka
  ]
}
