#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: setup SSL certs for EKS load balancer worker node instances.
#        see https://cert-manager.io/docs/
#------------------------------------------------------------------------------
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${domain}-tls
  namespace: ${namespace}
spec:
  secretName: ${domain}-tls
  issuerRef:
    kind: ClusterIssuer
    name: ${cluster_issuer}
  commonName: ${domain}
  dnsNames:
    - "${domain}"
    - "*.${domain}"
