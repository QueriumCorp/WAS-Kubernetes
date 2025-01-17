serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${role_arn}
  name: cert-manager
  namespace: ${namespace}
# the securityContext is required, so the pod can access files required to assume the IAM role
securityContext:
  # -------------------------------------------------------------------------------
  # mcdaniel dec-2022: see https://github.com/cert-manager/cert-manager/issues/5549
  #enabled: true
  # -------------------------------------------------------------------------------
  fsGroup: 1001
installCRDs: true
affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: querium.com/node-group
            operator: In
            values:
            - ${nodegroup}
tolerations:
- key: querium.com/service-only
  operator: Exists
  effect: NoSchedule
cainjector:
  tolerations:
  - key: querium.com/service-only
    operator: Exists
    effect: NoSchedule
webhook:
  tolerations:
  - key: querium.com/service-only
    operator: Exists
    effect: NoSchedule
startupapicheck:
  tolerations:
  - key: querium.com/service-only
    operator: Exists
    effect: NoSchedule
