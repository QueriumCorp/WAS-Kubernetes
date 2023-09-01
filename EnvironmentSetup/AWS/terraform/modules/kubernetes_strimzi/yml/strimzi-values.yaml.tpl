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
