

resource "kubernetes_persistent_volume_claim_v1" "awes" {
  metadata {
    name = "awes-logs"
    namespace = "was"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume_v1.awes.metadata.0.name}"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "awes" {
  metadata {
    name = "awes-nodefiles"
    namespace = "was"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume_v1.awes.metadata.0.name}"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "awes" {
  metadata {
    name = "endpoint-logs"
    namespace = "was"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume_v1.awes.metadata.0.name}"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "awes" {
  metadata {
    name = "resources-logs"
    namespace = "was"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume_v1.awes.metadata.0.name}"
  }
}
