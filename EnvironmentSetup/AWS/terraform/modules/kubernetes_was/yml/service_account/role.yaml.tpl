apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: awesrestartpods
  namespace: ${namespace}
  labels:
    k8s-app: ${namespace}-awes
rules:
- apiGroups: ["apps"]
  resources:
  - deployments
  verbs:
  - patch
  - get
