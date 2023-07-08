apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: was-ingress-resources
  namespace: ${namespace}
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /resources/$1
spec:
  rules:
  - http:
      paths:
        - path: /resources/?(.*)
          pathType: Prefix
          backend:
            service:
              name: resource-manager
              port:
                number: 9090