#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: setup nginx for EKS load balancer.
#        see https://cert-manager.io/docs/
#------------------------------------------------------------------------------
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: prometheus-grafana
  namespace: prometheus
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: ${domain}
spec:
  tls:
  - hosts:
    - "grafana.${domain}"
    secretName: ${domain}-tls
  rules:
  - host: grafana.${domain}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: prometheus-grafana
            port:
              number: 3000
