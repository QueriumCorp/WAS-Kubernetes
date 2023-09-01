kubecostToken: ${kubecostToken}
global:
  grafana:
    enabled: false
kubecostMetrics:
  exporter:
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
prometheus:
  kubeStateMetrics:
    enabled: false
  server:
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
networkCosts:
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
grafana: