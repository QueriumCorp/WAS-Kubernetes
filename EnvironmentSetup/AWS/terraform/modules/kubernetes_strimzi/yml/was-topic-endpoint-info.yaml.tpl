apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: endpoint-info
  namespace: ${kafka_namespace}
  labels:
    strimzi.io/cluster: ${name}
spec:
  partitions: 2
  replicas: 3
  config:
    retention.bytes: -1
    retention.ms: -1
    cleanup.policy: compact
    min.cleanable.dirty.ratio: 0.05
  topicName: endpoint-info
