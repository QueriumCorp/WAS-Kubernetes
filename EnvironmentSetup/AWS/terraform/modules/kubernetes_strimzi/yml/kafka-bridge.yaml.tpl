apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaBridge
metadata:
  name: kafka
  namespace: kafka
spec:
  replicas: 1
  bootstrapServers: ${name}-kafka-bootstrap:9092
  http:
    port: 9092
