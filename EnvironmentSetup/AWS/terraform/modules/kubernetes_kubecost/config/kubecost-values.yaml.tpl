kubecostToken: ${kubecostToken}
global:
  grafana:
    enabled: true
kubecostMetrics:
  exporter:
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
prometheus:
  kubeStateMetrics:
    enabled: true
  server:
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
networkCosts:
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
grafana: