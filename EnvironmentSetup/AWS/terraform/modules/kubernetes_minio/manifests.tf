

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------


resource "kubectl_manifest" "hpa-autoscaler-minio" {
  yaml_body = data.template_file.hpa-autoscaler-minio.rendered
}

