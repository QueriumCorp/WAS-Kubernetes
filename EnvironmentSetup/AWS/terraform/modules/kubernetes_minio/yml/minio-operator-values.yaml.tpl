operator:
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
  - key: querium.com/was-only
    operator: Exists
    effect: NoSchedule
console:
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
  - key: querium.com/was-only
    operator: Exists
    effect: NoSchedule
