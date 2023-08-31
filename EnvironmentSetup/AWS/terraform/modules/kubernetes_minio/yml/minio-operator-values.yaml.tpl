operator:
  affinity:
      nodeAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          preference:
            matchExpressions:
            - key: querium.com/node-group
              operator: In
              values:
              - ${nodegroup}
  tolerations:
  - key: querium.com/was-only
    operator: Exists
    effect: NoSchedule
console:
  affinity:
      nodeAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          preference:
            matchExpressions:
            - key: querium.com/node-group
              operator: In
              values:
              - ${nodegroup}
  tolerations:
  - key: querium.com/was-only
    operator: Exists
    effect: NoSchedule
