apiVersion: v1
kind: Service
metadata:
  labels:
    app: resource-manager
  name: resource-manager
  namespace: ${namespace}
spec:
  ports:
  - name: "9090"
    port: 9090
    targetPort: 9090
  selector:
    app: resource-manager
