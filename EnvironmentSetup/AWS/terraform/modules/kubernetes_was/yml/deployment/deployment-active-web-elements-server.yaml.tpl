# https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/
apiVersion: apps/v1
kind: Deployment
metadata:
  name: active-web-elements-server-deployment
  namespace: ${namespace}
  labels:
    app: active-web-elements-server
spec:
  selector:
    matchLabels:
      app: active-web-elements-server
  minReadySeconds: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 50%
      maxUnavailable: 50%
  template:
    metadata:
      labels:
        app: active-web-elements-server
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
        - name: SPRING_PROFILES_ACTIVE
          value: docker
        - name: LOG_LOCATION
          value: /opt/app/logs
        - name: APPLICATIONSERVER_CACHEDIRECTORY
          value: /tmp/.wolframcache
        - name: KAFKA.BOOTSTRAP-SERVERS
          value: ${namespace}-kafka-bootstrap.kafka.svc.cluster.local:9092
        - name: applicationserver.nodefiles.cachedirectory
          value: /opt/.wolframcache/nodefiles/
        - name: applicationserver.version
          value: "3.3.2"
        - name: applicationserver.wolframEngineVersion
          value: "13.2.0"
        - name: applicationserver.kernelinitializationfile.name
          value: init.m
        - name: poolconfiguration_kernelpool_0__KernelNumber
          value: "2"
        - name: poolconfiguration_kernelpool_0__KernelPoolName
          value: MSP
        - name: poolconfiguration_kernelpool_0__JLinkEnabled
          value: "true"
        - name: poolconfiguration_kernelpool_1__KernelNumber
          value: "2"
        - name: poolconfiguration_kernelpool_1__KernelPoolName
          value: Public
        - name: poolconfiguration_kernelpool_1__JLinkEnabled
          value: "false"
        - name: applicationserver.servername
          value: "https://${domain}/"
        - name: applicationserver.resourcemanager.url
          value: "https://${domain}/resources/"
        - name: applicationserver.nodefilesmanager.url
          value: "https://${domain}/nodefiles/"
        - name: applicationserver.endpointmanager.url
          value: "https://${domain}/endpoints/"
        - name: applicationserver.restart.url
          value: "https://${domain}/.applicationserver/kernel/restart"
        image: wolframapplicationserver/active-web-elements-server:${was_active_web_elements_server_version}
        name: active-web-elements-server
        ports:
        - containerPort: 8080
        - containerPort: 8181
        resources:
          limits:
            cpu: 3
            memory: 6Gi
          requests:
            cpu: 2
            memory: 6Gi
        startupProbe:
          httpGet:
            path: /.applicationserver/info
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 20
          failureThreshold: 10
        readinessProbe:
          httpGet:
            path: /.applicationserver/info
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 20
        livenessProbe:
          httpGet:
            path: /.applicationserver/info
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 20
        volumeMounts:
        - mountPath: "/opt/.wolframcache/nodefiles/"
          name: awes-nodefiles-storage
        - mountPath: "/opt/app/logs"
          name: awes-logs-storage
      initContainers:
      - name: init-resource-manager
        image: bash
        command: ["bash", "-c", "for i in $(seq 1 3000); do nc -zvw1 resource-manager 9090 && exit 0 || sleep 3; done; exit 1"]
      - name: init-endpoint-manager
        image: bash
        command: ["bash", "-c", "for i in $(seq 1 3000); do nc -zvw1 endpoint-manager 8085 && exit 0 || sleep 3; done; exit 1"]
      volumes:
        - name: awes-nodefiles-storage
          persistentVolumeClaim:
            claimName: awes-nodefiles
        - name: awes-logs-storage
          persistentVolumeClaim:
            claimName: awes-logs
