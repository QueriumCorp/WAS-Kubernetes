
data "template_file" "kafka-persistent" {
  template = file("${path.module}/yml/kafka-persistent.yaml")
  vars = {}
}

data "template_file" "kafka-topic" {
  template = file("${path.module}/yml/kafka-topic.yaml")
  vars = {}
}

data "template_file" "kafka-bridge" {
  template = file("${path.module}/yml/kafka-bridge.yaml")
  vars = {}
}

resource "kubectl_manifest" "kafka-persistent" {
  yaml_body = data.template_file.kafka-persistent.rendered
  depends_on = [ module.eks ]
}

resource "kubectl_manifest" "kafka-topic" {
  yaml_body = data.template_file.kafka-topic.rendered
  depends_on = [ module.eks ]
}

resource "kubectl_manifest" "kafka-bridge" {
  yaml_body = data.template_file.kafka-bridge.rendered
  depends_on = [ module.eks ]
}
