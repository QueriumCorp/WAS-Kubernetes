admissionController:
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



recommender:
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
updater:
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

crds:
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
