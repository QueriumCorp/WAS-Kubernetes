## Secret with default environment variable configurations to be used by MinIO Tenant.
## Not recommended for production deployments! Create the secret manually instead.
secrets:
  name: ${secretsName}
  # MinIO root user and password
  accessKey: ${secretsAccessKey}
  secretKey: ${secretsSecretKey}
  ## Set the value for existingSecret to use a pre created secret and dont create default one
  # existingSecret: random-env-configuration
## MinIO Tenant Definition
tenant:
  # Tenant name
  name: ${tenantName}
  ## The secret is expected to have a key named config.env containing environment variables exports.
  configuration:
    name: ${tenantConfigurationName}
  ## Specification for MinIO Pool(s) in this Tenant.
  pools:
    ## Servers specifies the number of MinIO Tenant Pods / Servers in this pool.
    ## For standalone mode, supply 1. For distributed mode, supply 4 or more.
    ## Note that the operator does not support upgrading from standalone to distributed mode.
    - servers: ${tenantPoolsServers}
      ## custom name for the pool
      name: pool-0
      ## volumesPerServer specifies the number of volumes attached per MinIO Tenant Pod / Server.
      volumesPerServer: ${tenantPoolsVolumesPerServer}
      ## size specifies the capacity per volume
      size: ${tenantPoolsSize}
      ## storageClass specifies the storage class name to be used for this pool
      storageClassName: standard
      ## Used to specify annotations for pods
      annotations: { }
      ## Used to specify labels for pods
      labels: { }
      ## Used to specify a toleration for a pod
      tolerations: [ ]
      ## nodeSelector parameters for MinIO Pods. It specifies a map of key-value pairs. For the pod to be
      ## eligible to run on a node, the node must have each of the
      ## indicated key-value pairs as labels.
      ## Read more here: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
      nodeSelector: { }
      ## Affinity settings for MinIO pods. Read more about affinity
      ## here: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity.
      affinity: { }
ingress:
  api:
    enabled: false
    ingressClassName: ""
    labels: { }
    annotations: { }
    tls: [ ]
    host: minio.local
    path: /
    pathType: Prefix
  console:
    enabled: false
    ingressClassName: ""
    labels: { }
    annotations: { }
    tls: [ ]
    host: minio-console.local
    path: /
    pathType: Prefix
