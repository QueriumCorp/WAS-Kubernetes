controller:
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
  - key: querium.com/service-only
    operator: Exists
    effect: NoSchedule
  admissionWebhooks:
    patch:
      tolerations:
      - key: querium.com/service-only
      operator: Exists
      effect: NoSchedule
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
defaultBackend:
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
  - key: querium.com/service-only
    operator: Exists
    effect: NoSchedule


