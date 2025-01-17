# https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/
apiVersion: apps/v1
kind: Deployment
metadata:
  name: endpoint-manager-deployment
  namespace: ${namespace}
  labels:
    app: endpoint-manager
spec:
  selector:
    matchLabels:
      app: endpoint-manager
  minReadySeconds: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 50%
      maxUnavailable: 50%
  template:
    metadata:
      labels:
        app: endpoint-manager
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: querium.com/node-group
                operator: In
                values:
                - ${namespace}
      tolerations:
      - key: querium.com/was-only
        operator: Exists
        effect: NoSchedule
      serviceAccountName: awesrestartpods
      restartPolicy: Always
      containers:
      - env:
        - name: SPRING_PROFILES_ACTIVE
          value: docker
        - name: LOG_LOCATION
          value: /opt/app/logs
        - name: KAFKA.BOOTSTRAP-SERVERS
          value: ${namespace}-kafka-bootstrap.kafka.svc.cluster.local:9092
        image: wolframapplicationserver/endpoint-manager:${was_endpoint_manager_version}
        name: endpoint-manager
        ports:
        - containerPort: 8085
        resources:
          limits:
            cpu: "1000m"
            memory: 1Gi
          requests:
            cpu: "500m"
            memory: 500Mi
        readinessProbe:
          tcpSocket:
            port: 8085
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          tcpSocket:
            port: 8085
          initialDelaySeconds: 15
          periodSeconds: 20
        volumeMounts:
        - mountPath: "/opt/app/logs"
          name: endpoint-logs-storage
      initContainers:
      - name: init-kafka
        image: bash
        command: ["bash", "-c", "for i in $(seq 1 3000); do nc -zvw1 ${namespace}-kafka-bootstrap.kafka.svc.cluster.local 9092 && exit 0 || sleep 3; done; exit 1"]
      - name: init-kafka-resources-topic
        image: bash
        command: ["bash", "-c", "apk --update add curl; set -x; while true; do response=$(curl -s ${namespace}-bridge-service.kafka.svc.cluster.local:9092/topics); if [[ ${response} =~ .*\"resource-info\".* ]]; then break; else sleep 5; fi; done" ]
      - name: init-kafka-endpoints-topic
        image: bash
        command: ["bash", "-c", "apk --update add curl; set -x; while true; do response=$(curl -s ${namespace}-bridge-service.kafka.svc.cluster.local:9092/topics); if [[ ${response} =~ .*\"endpoint-info\".* ]]; then break; else sleep 5; fi; done" ]
      - name: init-kafka-nodefiles-topic
        image: bash
        command: ["bash", "-c", "apk --update add curl; set -x; while true; do response=$(curl -s ${namespace}-bridge-service.kafka.svc.cluster.local:9092/topics); if [[ ${response} =~ .*\"nodefile-info\".* ]]; then break; else sleep 5; fi; done" ]
      - name: init-minio
        image: bash
        command: ["bash", "-c", "for i in $(seq 1 3000); do nc -zvw1 ${namespace}-minio-tenant-hl.${namespace}.svc.cluster.local 9000 && exit 0 || sleep 3; done; exit 1"]
      volumes:
        - name: endpoint-logs-storage
          persistentVolumeClaim:
            claimName: endpoint-logs
