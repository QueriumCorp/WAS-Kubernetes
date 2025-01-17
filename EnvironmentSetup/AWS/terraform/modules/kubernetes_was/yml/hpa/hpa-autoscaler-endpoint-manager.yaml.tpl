apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
 name: endpoint-manager-hpa
 namespace: ${namespace}
spec:
 scaleTargetRef:
   apiVersion: apps/v1
   kind: Deployment
   name: endpoint-manager-deployment
 minReplicas: 1
 maxReplicas: 1
 metrics:
 - type: Resource
   resource:
    name: cpu
    target:
      type: Utilization
      averageUtilization: 85
 - type: Resource
   resource:
    name: memory
    target:
      type: Utilization
      averageUtilization: 90
