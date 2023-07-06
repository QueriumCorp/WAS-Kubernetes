resource "kubernetes_namespace" "was" {
  metadata {
    name = "was"
  }
  depends_on = [module.eks]
}

