data "template_file" "role-binding" {
  template = file("${path.module}/yml/service_account/role-binding.yaml.tpl")
  vars = {
    namespace = var.namespace
  }
}

data "template_file" "role" {
  template = file("${path.module}/yml/service_account/role.yaml.tpl")
  vars = {
    namespace = var.namespace
  }
}

data "template_file" "service-account" {
  template = file("${path.module}/yml/service_account/service-account.yaml.tpl")
  vars = {
    namespace = var.namespace
  }
}



#------------------------------------------------------------------------------
#                             resources
#------------------------------------------------------------------------------
resource "kubectl_manifest" "role-binding" {
  yaml_body = data.template_file.role-binding.rendered
}

resource "kubectl_manifest" "role" {
  yaml_body = data.template_file.role.rendered
}

resource "kubectl_manifest" "service-account" {
  yaml_body = data.template_file.service-account.rendered
}
