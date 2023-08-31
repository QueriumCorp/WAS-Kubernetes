# https://strimzi.io/docs/operators/latest/full/deploying#assembly-scheduling-str
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: ${name}
  namespace: ${kafka_namespace}
spec:
  kafka:
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
    version: 3.4.0
    replicas: 3
    listeners:
      - name: plain
        port: 9092
        type: internal
        tls: false
      - name: tls
        port: 9093
        type: internal
        tls: true
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
      default.replication.factor: 3
      min.insync.replicas: 3
      inter.broker.protocol.version: "3.4"
    storage:
      type: jbod
      volumes:
      - id: 0
        type: persistent-claim
        size: 100Gi
        deleteClaim: false
  zookeeper:
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
    replicas: 3
    storage:
      type: persistent-claim
      size: 100Gi
      class: gp3
      deleteClaim: false
  entityOperator:
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
