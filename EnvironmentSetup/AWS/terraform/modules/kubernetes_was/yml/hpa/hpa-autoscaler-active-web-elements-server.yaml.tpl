apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
 name: active-web-elements-server-hpa
 namespace: ${namespace}
spec:
 scaleTargetRef:
   apiVersion: apps/v1
   kind: Deployment
   name: active-web-elements-server-deployment
 minReplicas: 1
 maxReplicas: 1
 metrics:
  - type: Object
    object:
      metric:
        name: MSP_RecentMaxKernelPercentageUse
      describedObject:
        kind: Service
        name: active-web-elements-server
      target:
        averageValue: 90
        type: AverageValue
  - type: Object
    object:
      metric:
        name: MSP_QueueSize
      describedObject:
        kind: Service
        name: active-web-elements-server
      target:
        averageValue: 2
        type: AverageValue
  - type: Object
    object:
      metric:
        name: Public_RecentMaxKernelPercentageUse
      describedObject:
        kind: Service
        name: active-web-elements-server
      target:
        averageValue: 90
        type: AverageValue
  - type: Object
    object:
      metric:
        name: Public_QueueSize
      describedObject:
        kind: Service
        name: active-web-elements-server
      target:
        averageValue: 2
        type: AverageValue
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
