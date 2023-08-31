# https://strimzi.io/docs/operators/latest/full/deploying#assembly-scheduling-str
# KafkaBridge.spec.template.pod
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
  template:
    pod:
      affinity:
          nodeAffinity:
            preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              preference:
                matchExpressions:
                - key: querium.com/node-group
                  operator: In
                  values:
                  - ${name}
      tolerations:
      - key: querium.com/was-only
        operator: Exists
        effect: NoSchedule
