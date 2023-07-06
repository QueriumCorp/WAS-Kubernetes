#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: installs kafka scaling service.
# see: https://kafka.sh/v0.19.3/getting-started/getting-started-with-terraform/
#
# requirements: you must initialize a local helm repo in order to run
# this mdoule.
#
#   brew install helm
#   helm repo add kafka https://charts.kafka.sh/
#   helm repo update
#   helm search repo kafka
#   helm show values kafka/kafka
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#-----------------------------------------------------------
# FIX NOTE: the policy lacks some permissions for creating/terminating instances
#  as well as pricing:GetProducts.
#
# FIXED. but see note below about version.
#
# see: https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-role-for-service-accounts-eks
locals {
  kafka_namespace = "kafka"

  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source"    = "openedx_devops/terraform/stacks/modules/kubernetes_kafka"
      "cookiecutter/resource/source"  = "charts.kafka.sh"
      "cookiecutter/resource/version" = "0.16"
    }
  )
}

data "template_file" "kafka-values" {
  template = file("${path.module}/yml/kafka-values.yaml")
}


resource "helm_release" "kafka" {
  namespace        = local.kafka_namespace
  create_namespace = true

  name       = "kafka"
  repository = "https://charts.kafka.sh"
  chart      = "kafka"

  version = "~> 0.16"

  values = [
    data.template_file.kafka-values.rendered
  ]

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.kafka_controller_irsa_role.iam_role_arn
  }

  set {
    name  = "clusterName"
    value = var.stack_namespace
  }

  set {
    name  = "clusterEndpoint"
    value = data.aws_eks_cluster.eks.endpoint
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.kafka.name
  }

}

#------------------------------------------------------------------------------
#                           SUPPORTING RESOURCES
#------------------------------------------------------------------------------
module "kafka_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  # mcdaniel aug-2022: specifying an explicit version causes this module to create
  # an incomplete IAM policy.
  #version = "~> 5.3"

  role_name                          = "kafka-controller-${var.stack_namespace}"
  create_role                        = true
  attach_kafka_controller_policy = true

  kafka_controller_cluster_id = data.aws_eks_cluster.eks.name
  kafka_controller_node_iam_role_arns = [
    var.service_node_group_iam_role_arn
  ]

  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kafka:kafka"]
    }
  }

  tags = merge(
    local.tags,
    {
      "cookiecutter/resource/source"  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
      "cookiecutter/resource/version" = "latest"
    }
  )

}


resource "random_pet" "this" {
  length = 2
}

resource "aws_iam_instance_profile" "kafka" {
  name = "kafkaNodeInstanceProfile-${var.stack_namespace}-${random_pet.this.id}"
  role = var.service_node_group_iam_role_name
}


# see: https://kafka.sh/v0.6.1/provisioner/
resource "kubectl_manifest" "kafka_provisioner" {
  yaml_body = <<-YAML
  apiVersion: kafka.sh/v1alpha5
  kind: Provisioner
  metadata:
    name: default
  spec:
    requirements:
      - key: kafka.sh/capacity-type
        operator: In
        values: ["spot", "on-demand"]
      - key: node.kubernetes.io/instance-type
        operator: In
        values: ["t3.2xlarge", "t3.xlarge", "t2.2xlarge", "t3.large", "t2.xlarge"]
    limits:
      resources:
        cpu: "400"        # 100 * 4 cpu
        memory: 1600Gi    # 100 * 16Gi
    provider:
      subnetSelector:
        kafka.sh/discovery: ${var.stack_namespace}
      securityGroupSelector:
        kafka.sh/discovery: ${var.stack_namespace}
      tags:
        kafka.sh/discovery: ${var.stack_namespace}

    # If nil, the feature is disabled, nodes will never terminate
    ttlSecondsUntilExpired: 600           # 10 minutes = 60 seconds * 10 minutes

    # If nil, the feature is disabled, nodes will never scale down due to low utilization
    ttlSecondsAfterEmpty: 600             # 10 minutes = 60 seconds * 10 minutes
  YAML

  depends_on = [
    helm_release.kafka
  ]
}

resource "aws_iam_role" "ec2_spot_fleet_tagging_role" {
  name = "AmazonEC2SpotFleetTaggingRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "spotfleet.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.tags,
    {
      "cookiecutter/resource/source"  = "hashicorp/aws/aws_iam_role"
      "cookiecutter/resource/version" = "4.48"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ec2_spot_fleet_tagging" {
  role       = aws_iam_role.ec2_spot_fleet_tagging_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}

resource "kubectl_manifest" "vpa-kafka" {
  yaml_body = file("${path.module}/yml/vpa-kafka.yaml")

  depends_on = [
    helm_release.kafka
  ]
}

#------------------------------------------------------------------------------
#                               COOKIECUTTER META
#------------------------------------------------------------------------------
module "cookiecutter_meta" {
  source = "../../../../../../../common/cookiecutter_meta"
}

resource "kubernetes_secret" "cookiecutter" {
  metadata {
    name      = "cookiecutter-terraform"
    namespace = local.kafka_namespace
  }

  # https://stackoverflow.com/questions/64134699/terraform-map-to-string-value
  data = {
    tags = jsonencode(local.tags)
  }
}
