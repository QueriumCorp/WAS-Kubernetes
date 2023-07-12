apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaBridge
metadata:
  name: ${name}
  namespace: ${kafka_namespace}
spec:
  replicas: 1
  bootstrapServers: ${name}-kafka-bootstrap:9092
  http:
    port: 9092
