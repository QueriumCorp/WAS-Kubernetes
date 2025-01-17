apiVersion: v1
kind: Service
metadata:
  labels:
    app: endpoint-manager
  name: endpoint-manager
  namespace: ${namespace}
spec:
  ports:
  - name: "8085"
    port: 8085
    targetPort: 8085
  selector:
    app: endpoint-manager
