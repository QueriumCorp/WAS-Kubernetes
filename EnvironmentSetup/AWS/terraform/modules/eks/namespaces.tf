resource "kubernetes_namespace" "was" {
  metadata {
    name = var.namespace
  }
  depends_on = [module.eks]
}

