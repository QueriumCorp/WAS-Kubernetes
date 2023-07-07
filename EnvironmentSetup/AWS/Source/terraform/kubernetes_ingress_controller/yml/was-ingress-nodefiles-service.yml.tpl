apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: was-ingress-nodefiles
  namespace: ${namespace}
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: 1g
    nginx.ingress.kubernetes.io/rewrite-target: /nodefiles/$1
spec:
  rules:
  - http:
      paths:
        - path: /nodefiles/?(.*)
          pathType: Prefix
          backend:
            service:
              name: resource-manager
              port:
                number: 9090