

resource "kubernetes_persistent_volume_claim_v1" "awes-logs" {
  metadata {
    name      = "awes-logs"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.awes-logs.metadata.0.name
  }
}

resource "kubernetes_persistent_volume" "awes-logs" {
  metadata {
    name = "awes-logs"
    labels = {
      "topology.kubernetes.io/region" = "${var.aws_region}"
      "topology.kubernetes.io/zone"   = "${aws_ebs_volume.awes-logs.availability_zone}"
      "ebs_volume_id"                 = "${aws_ebs_volume.awes-logs.id}"
      "name"                          = "awes-logs"
      "namespace"                     = var.namespace
    }
    annotations = {
    }
  }

  spec {
    capacity = {
      storage = "10Gi"
    }
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "gp2"
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = aws_ebs_volume.awes-logs.id
        fs_type   = "ext4"
      }
    }
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "topology.kubernetes.io/zone"
            operator = "In"
            values   = ["${aws_ebs_volume.awes-logs.availability_zone}"]
          }
          match_expressions {
            key      = "topology.kubernetes.io/region"
            operator = "In"
            values   = ["${var.aws_region}"]
          }
        }
      }
    }
  }

  depends_on = [
    aws_ebs_volume.awes-logs
  ]
}

# create a detachable EBS volume for awes-logs
#------------------------------------------------------------------------------
#                     AWS ELASTIC BLOCK STORE RESOURCES
#------------------------------------------------------------------------------
resource "aws_ebs_volume" "awes-logs" {
  availability_zone = data.aws_subnet.private_subnet.availability_zone
  size              = 10

  tags = var.tags

  # local.ebsVolumePreventDestroy defaults to 'Y'
  # for anything other than an upper case 'N' we'll assume that
  # we should not destroy this resource.
  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    data.aws_subnet.private_subnet
  ]
}
