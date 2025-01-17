apiVersion: v1
kind: Service
metadata:
  labels:
    app: active-web-elements-server
  name: active-web-elements-server
  namespace: ${namespace}
  annotations:
      prometheus.io/scrape: 'true'
      prometheus.io/path:   /metrics
      prometheus.io/port:   '8181'
spec:
  ports:
  - name: "8080"
    port: 8080
    targetPort: 8080
  - name: "8181"
    port: 8181
    targetPort: 8181
  selector:
    app: active-web-elements-server
