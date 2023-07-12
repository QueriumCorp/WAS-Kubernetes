apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: endpoint-info
  namespace: ${name}
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
---
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: resource-info
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
  topicName: resource-info
---
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: nodefile-info
  namespace: ${name}
  labels:
    strimzi.io/cluster: ${name}
spec:
  partitions: 2
  replicas: 3
  config:
    retention.bytes: -1
    retention.ms: -1
    cleanup.policy: compact
    min.cleanable.dirty.ratio: 0
    segment.ms: 100
  topicName: nodefile-info
