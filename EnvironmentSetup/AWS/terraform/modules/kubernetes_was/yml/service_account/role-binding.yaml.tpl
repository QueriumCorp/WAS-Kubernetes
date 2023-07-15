apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: awesrestartpods
subjects:
- kind: ServiceAccount
  name: awesrestartpods
  namespace: ${namespace}
roleRef:
  kind: Role
  name: awesrestartpods
  apiGroup: rbac.authorization.k8s.io
