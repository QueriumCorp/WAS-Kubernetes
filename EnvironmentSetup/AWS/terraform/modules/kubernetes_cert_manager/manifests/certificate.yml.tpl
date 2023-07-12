apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${services_subdomain}-tls
  namespace: ${namespace}
spec:
  secretName: ${services_subdomain}-tls
  issuerRef:
    kind: ClusterIssuer
    name: ${services_subdomain}
  commonName: ${services_subdomain}
  dnsNames:
    - "${services_subdomain}"
    - "*.${services_subdomain}"
