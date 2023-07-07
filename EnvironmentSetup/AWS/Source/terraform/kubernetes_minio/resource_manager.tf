data "template_file" "resource-manager-service" {
  template = file("${path.module}/yml/resource-manager-service.yaml")
  vars = {}
}


data "template_file" "deployment-resource-manager" {
  template = file("${path.module}/yml/deployment-resource-manager.yaml.tpl")
  vars = {
    minio_access_key="set-me-please"
    minio_secret_key=""
    resource_info_bucket=""
    nodefiles_bucket=""
    resource_bucket_region=""
    nodefiles_bucket_region=""
  }
}

resource "kubectl_manifest" "resource-manager-service" {
  yaml_body = data.template_file.resource-manager-service.rendered
  depends_on = [ module.eks ]
}


resource "kubectl_manifest" "deployment-resource-manager" {
  yaml_body = data.template_file.deployment-resource-manager.rendered
  depends_on = [ 
    module.eks,
    kubectl_manifest.resource-manager-service
  ]
}

