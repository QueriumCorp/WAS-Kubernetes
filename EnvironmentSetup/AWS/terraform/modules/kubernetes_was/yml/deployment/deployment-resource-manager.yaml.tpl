# https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-manager-deployment
  namespace: ${namespace}
  labels:
    app: resource-manager
spec:
  selector:
    matchLabels:
      app: resource-manager
  minReadySeconds: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 50%
      maxUnavailable: 50%
  template:
    metadata:
      labels:
        app: resource-manager
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
      restartPolicy: Always
      containers:
      - env:
        - name: JAVA_OPTS
          value: "-Xms1024m -Xmx2048m"
        - name: SPRING_PROFILES_ACTIVE
          value: docker
        - name: LOG_LOCATION
          value: /opt/app/logs
        - name: KAFKA.BOOTSTRAP-SERVERS
          value: ${namespace}-kafka-bootstrap.kafka.svc.cluster.local:9092
        - name: MINIOACCESSKEY
          value: ${minio_access_key}
        - name: MINIOSECRETKEY
          value: ${minio_secret_key}
        - name: RESOURCEINFO.BUCKET
          value: ${resource_info_bucket}
        - name: NODEFILES.BUCKET
          value: ${nodefiles_bucket}
        - name: RESOURCE.BUCKET.REGION
          value: ${resource_bucket_region}
        - name: NODEFILES.BUCKET.REGION
          value: ${nodefiles_bucket_region}
        image: wolframapplicationserver/resource-manager:${was_resource_manager_version}
        name: resource-manager
        ports:
        - containerPort: 9090
        resources:
          limits:
            cpu: "1000m"
            memory: 4Gi
          requests:
            cpu: "500m"
            memory: 2000Mi
        readinessProbe:
          tcpSocket:
            port: 9090
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          tcpSocket:
            port: 9090
          initialDelaySeconds: 15
          periodSeconds: 20
        volumeMounts:
        - mountPath: "/opt/app/logs"
          name: resources-logs-storage
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
        - name: resources-logs-storage
          persistentVolumeClaim:
            claimName: resources-logs
