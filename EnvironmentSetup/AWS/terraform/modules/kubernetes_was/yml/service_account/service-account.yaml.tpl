apiVersion: v1
kind: ServiceAccount
metadata:
  name: awesrestartpods
  namespace: ${namespace}
  labels:
    k8s-app: ${namespace}-awes
