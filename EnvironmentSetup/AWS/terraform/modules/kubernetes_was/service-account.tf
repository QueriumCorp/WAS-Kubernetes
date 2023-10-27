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
resource "kubernetes_manifest" "role-binding" {
  manifest = yamldecode(data.template_file.role-binding.rendered)
}

resource "kubernetes_manifest" "role" {
  manifest = yamldecode(data.template_file.role.rendered)
}

resource "kubernetes_manifest" "service-account" {
  manifest = yamldecode(data.template_file.service-account.rendered)
}
