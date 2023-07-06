apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minio
  namespace: minio
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: live.stepwisemath.ai
spec:
  tls:
  - hosts:
    - "minio.live.stepwisemath.ai"
    secretName: live.stepwisemath.ai-tls
  rules:
  - host: minio.live.stepwisemath.ai
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: minio
            port:
              number: 80
