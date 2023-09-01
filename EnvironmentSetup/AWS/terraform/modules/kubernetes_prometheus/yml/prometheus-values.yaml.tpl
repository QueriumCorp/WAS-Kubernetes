alertmanager:
  alertmanagerSpec:
    tolerations:
    - key: querium.com/service-only
      operator: Exists
      effect: NoSchedule
    - key: querium.com/was-only
      operator: Exists
      effect: NoSchedule
prometheusOperator:
  admissionWebhooks:
    patch:
      tolerations:
      - key: querium.com/service-only
        operator: Exists
        effect: NoSchedule
      - key: querium.com/was-only
        operator: Exists
        effect: NoSchedule
tolerations:
- key: querium.com/service-only
  operator: Exists
  effect: NoSchedule
- key: querium.com/was-only
  operator: Exists
  effect: NoSchedule
## Deploy a Prometheus instance
##
prometheus:
  ## Settings affecting prometheusSpec
  ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#prometheusspec
  ##
  prometheusSpec:
    ## Tolerations for use with node taints
    ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
    ##
    tolerations:
    - key: querium.com/service-only
      operator: Exists
      effect: NoSchedule
    - key: querium.com/was-only
      operator: Exists
      effect: NoSchedule
## Configuration for thanosRuler
## ref: https://thanos.io/tip/components/rule.md/
##
thanosRuler:
  ## Settings affecting thanosRulerpec
  ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#thanosrulerspec
  ##
  thanosRulerSpec:
    tolerations:
    - key: querium.com/service-only
      operator: Exists
      effect: NoSchedule
    - key: querium.com/was-only
      operator: Exists
      effect: NoSchedule
nodeExporter:
  enabled: false
