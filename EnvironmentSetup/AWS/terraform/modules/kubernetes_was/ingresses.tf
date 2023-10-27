#------------------------------------------------------------------------------
# endpoints
#------------------------------------------------------------------------------
data "template_file" "was-ingress-endpoints" {
  template = file("${path.module}/yml/ingress/was-ingress-endpoints.yaml.tpl")
  vars = {
    namespace = var.namespace
    domain    = var.domain
  }
}

resource "kubernetes_manifest" "was-ingress-endpoints" {
  manifest = yamldecode(data.template_file.was-ingress-endpoints.rendered)
}

#------------------------------------------------------------------------------
# nodefiles
#------------------------------------------------------------------------------
data "template_file" "was-ingress-nodefiles" {
  template = file("${path.module}/yml/ingress/was-ingress-nodefiles.yaml.tpl")
  vars = {
    namespace = var.namespace
    domain    = var.domain
  }
}

resource "kubernetes_manifest" "was-ingress-nodefiles" {
  manifest = yamldecode(data.template_file.was-ingress-nodefiles.rendered)
}

#------------------------------------------------------------------------------
# resources
#------------------------------------------------------------------------------
data "template_file" "was-ingress-resources" {
  template = file("${path.module}/yml/ingress/was-ingress-resources.yaml.tpl")
  vars = {
    namespace = var.namespace
    domain    = var.domain
  }
}

resource "kubernetes_manifest" "was-ingress-resources" {
  manifest = yamldecode(data.template_file.was-ingress-resources.rendered)
}

#------------------------------------------------------------------------------
# restart
#------------------------------------------------------------------------------
data "template_file" "was-ingress-restart" {
  template = file("${path.module}/yml/ingress/was-ingress-restart.yaml.tpl")
  vars = {
    namespace = var.namespace
    domain    = var.domain
  }
}

resource "kubernetes_manifest" "was-ingress-restart" {
  manifest = yamldecode(data.template_file.was-ingress-restart.rendered)
}

#------------------------------------------------------------------------------
# root
#------------------------------------------------------------------------------
data "template_file" "was-ingress-root" {
  template = file("${path.module}/yml/ingress/was-ingress-root.yaml.tpl")
  vars = {
    namespace = var.namespace
    domain    = var.domain
  }
}

resource "kubernetes_manifest" "was-ingress-root" {
  manifest = yamldecode(data.template_file.was-ingress-root.rendered)
}
