
resource "kubectl_manifest" "010-ServiceAccount-strimzi-cluster-operator" {
  yaml_body = file("${path.module}/yml/010-ServiceAccount-strimzi-cluster-operator.yaml")
  depends_on = [ module.eks ]
}

resource "kubectl_manifest" "020-ClusterRole-strimzi-cluster-operator-role" {
  yaml_body = file("${path.module}/yml/020-ClusterRole-strimzi-cluster-operator-role.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "020-RoleBinding-strimzi-cluster-operator" {
  yaml_body = file("${path.module}/yml/020-RoleBinding-strimzi-cluster-operator.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "021-ClusterRole-strimzi-cluster-operator-role" {
  yaml_body = file("${path.module}/yml/021-ClusterRole-strimzi-cluster-operator-role.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "021-ClusterRoleBinding-strimzi-cluster-operator" {
  yaml_body = file("${path.module}/yml/021-ClusterRoleBinding-strimzi-cluster-operator.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "030-ClusterRole-strimzi-kafka-broker" {
  yaml_body = file("${path.module}/yml/030-ClusterRole-strimzi-kafka-broker.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "030-ClusterRoleBinding-strimzi-cluster-operator-kafka-broker-delegation" {
  yaml_body = file("${path.module}/yml/030-ClusterRoleBinding-strimzi-cluster-operator-kafka-broker-delegation.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "031-ClusterRole-strimzi-entity-operator" {
  yaml_body = file("${path.module}/yml/031-ClusterRole-strimzi-entity-operator.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "031-RoleBinding-strimzi-cluster-operator-entity-operator-delegation" {
  yaml_body = file("${path.module}/yml/031-RoleBinding-strimzi-cluster-operator-entity-operator-delegation.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "032-ClusterRole-strimzi-topic-operator" {
  yaml_body = file("${path.module}/yml/032-ClusterRole-strimzi-topic-operator.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "032-RoleBinding-strimzi-cluster-operator-topic-operator-delegation" {
  yaml_body = file("${path.module}/yml/032-RoleBinding-strimzi-cluster-operator-topic-operator-delegation.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "033-ClusterRole-strimzi-kafka-client" {
  yaml_body = file("${path.module}/yml/033-ClusterRole-strimzi-kafka-client.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "033-ClusterRoleBinding-strimzi-cluster-operator-kafka-client-delegation" {
  yaml_body = file("${path.module}/yml/033-ClusterRoleBinding-strimzi-cluster-operator-kafka-client-delegation.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "040-Crd-kafka" {
  yaml_body = file("${path.module}/yml/040-Crd-kafka.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "041-Crd-kafkaconnect" {
  yaml_body = file("${path.module}/yml/041-Crd-kafkaconnect.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "042-Crd-kafkaconnects2i" {
  yaml_body = file("${path.module}/yml/042-Crd-kafkaconnects2i.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "043-Crd-kafkatopic" {
  yaml_body = file("${path.module}/yml/043-Crd-kafkatopic.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "044-Crd-kafkauser" {
  yaml_body = file("${path.module}/yml/044-Crd-kafkauser.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "045-Crd-kafkamirrormaker" {
  yaml_body = file("${path.module}/yml/045-Crd-kafkamirrormaker.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "046-Crd-kafkabridge" {
  yaml_body = file("${path.module}/yml/046-Crd-kafkabridge.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "047-Crd-kafkaconnector" {
  yaml_body = file("${path.module}/yml/047-Crd-kafkaconnector.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "048-Crd-kafkamirrormaker2" {
  yaml_body = file("${path.module}/yml/048-Crd-kafkamirrormaker2.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "049-Crd-kafkarebalance" {
  yaml_body = file("${path.module}/yml/049-Crd-kafkarebalance.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "050-ConfigMap-strimzi-cluster-operator" {
  yaml_body = file("${path.module}/yml/050-ConfigMap-strimzi-cluster-operator.yaml")
  depends_on = [ module.eks ]
}
resource "kubectl_manifest" "060-Deployment-strimzi-cluster-operator" {
  yaml_body = file("${path.module}/yml/060-Deployment-strimzi-cluster-operator.yaml")
  depends_on = [ module.eks ]
}
