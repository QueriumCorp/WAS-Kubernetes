

resource "kubernetes_persistent_volume_claim" "endpoint-logs" {
  metadata {
    name      = "endpoint-logs"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "gp3"
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.endpoint-logs.metadata[0].name
  }
}

resource "kubernetes_persistent_volume" "endpoint-logs" {
  metadata {
    name = "endpoint-logs"
    labels = {
      "topology.kubernetes.io/region" = var.aws_region
      "topology.kubernetes.io/zone"   = aws_ebs_volume.endpoint-logs.availability_zone
      "ebs_volume_id"                 = aws_ebs_volume.endpoint-logs.id
      "name"                          = "endpoint-logs"
      "namespace"                     = var.namespace
    }
    annotations = {
    }
  }

  spec {
    persistent_volume_reclaim_policy = "Delete"
    capacity = {
      storage = "10Gi"
    }
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "gp3"
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id   = aws_ebs_volume.endpoint-logs.id
        fs_type     = "ext4"
      }
    }
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "querium.com/node-group"
            operator = "In"
            values   = ["${var.namespace}"]
          }
          match_expressions {
            key      = "topology.kubernetes.io/zone"
            operator = "In"
            values   = [aws_ebs_volume.endpoint-logs.availability_zone]
          }
          match_expressions {
            key      = "topology.kubernetes.io/region"
            operator = "In"
            values   = [var.aws_region]
          }
        }
      }
    }
  }

  depends_on = [
    aws_ebs_volume.endpoint-logs
  ]
}

# create a detachable EBS volume for endpoint-logs
#------------------------------------------------------------------------------
#                     AWS ELASTIC BLOCK STORE RESOURCES
#------------------------------------------------------------------------------
resource "aws_ebs_volume" "endpoint-logs" {
  availability_zone = local.availability_zone
  size              = 10
  type              = "gp3"

  tags = merge(
    var.tags,
    {Name = "was-app-endpoint-logs"}
  )

  # local.ebsVolumePreventDestroy defaults to 'Y'
  # for anything other than an upper case 'N' we'll assume that
  # we should not destroy this resource.
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      tags,
      availability_zone
    ]
  }

  depends_on = [
    data.aws_subnet.private_subnet
  ]
}
