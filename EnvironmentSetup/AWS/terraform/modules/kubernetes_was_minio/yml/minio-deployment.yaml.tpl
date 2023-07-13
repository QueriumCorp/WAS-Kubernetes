apiVersion: apps/v1
kind: Deployment
metadata:
  name: minio-deployment
  namespace: ${namespace}
  labels:
    app: minio
spec:
  selector:
    matchLabels:
      app: minio
  minReadySeconds: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 50%
      maxUnavailable: 50%
  template:
    metadata:
      labels:
        app: minio
    spec:
      restartPolicy: Always
      containers:
      - env:
        - name: MINIO_ACCESS_KEY
          value: ${minio_access_key}
        - name: MINIO_SECRET_KEY
          value: ${minio_secret_key}
        - name: SERVER_ENDPOINT
          value: http://minio:9000
        image: wolframapplicationserver/minio:1.0.2
        name: minio
        command: ["sh", "-c", "/usr/bin/docker-entrypoint.sh gateway s3"]
        ports:
        - containerPort: 9000
        resources:
          limits:
            cpu: "200m"
            memory: 400Mi
          requests:
            cpu: "200m"
            memory: 400Mi
        readinessProbe:
          tcpSocket:
            port: 9000
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          tcpSocket:
            port: 9000
          initialDelaySeconds: 15
          periodSeconds: 20
