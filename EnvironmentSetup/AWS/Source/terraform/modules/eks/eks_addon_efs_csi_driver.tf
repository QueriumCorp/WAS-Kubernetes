#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Jul-2023
#
# Create the Amazon EFS CSI driver IAM role for service accounts
# https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html
#
#   helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
#   helm repo update aws-efs-csi-driver
#   helm repo update
#   helm search repo aws-efs-csi-driver/aws-efs-csi-driver
#   helm show values aws-efs-csi-driver/aws-efs-csi-driver
#
#  trouble shooting
#   helm uninstall aws-efs-csi-driver -n kube-system
#   helm list -A
#   terraform state rm helm_release.efs-csi-driver
#------------------------------------------------------------------------------

resource "aws_iam_policy" "AmazonEKS_EFS_CSI_Driver_Policy" {
  name        = "AmazonEKS_EFS_CSI_Driver_Policy"
  description = "WAS EFS Policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticfilesystem:DescribeAccessPoints",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeMountTargets",
          "ec2:DescribeAvailabilityZones"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticfilesystem:CreateAccessPoint"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringLike" : {
            "aws:RequestTag/efs.csi.aws.com/cluster" : "true"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticfilesystem:TagResource"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringLike" : {
            "aws:ResourceTag/efs.csi.aws.com/cluster" : "true"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : "elasticfilesystem:DeleteAccessPoint",
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/efs.csi.aws.com/cluster" : "true"
          }
        }
      }
    ]
  })
}

# 2. Create the IAM role.
resource "aws_iam_role" "AmazonEKS_EFS_CSI_DriverRoleWAS" {
  name = "AmazonEKS_EFS_CSI_DriverRoleWAS"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${var.account_id}:oidc-provider/oidc.eks.${var.aws_region}.amazonaws.com/id/D166659358A4D92DFF5FD0B97C0E2899"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "oidc.eks.${var.aws_region}.amazonaws.com/id/D166659358A4D92DFF5FD0B97C0E2899:sub" : "system:serviceaccount:kube-system:efs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

# 3. Attach the required AWS managed policy to the role
resource "aws_iam_role_policy_attachment" "aws_efs_csi_driver" {
  role       = aws_iam_role.AmazonEKS_EFS_CSI_DriverRoleWAS.name
  policy_arn = aws_iam_policy.AmazonEKS_EFS_CSI_Driver_Policy.arn
}

# 5. Create a service account with the ARN of the IAM role
data "template_file" "efs-service-account" {
  template = file("${path.module}/yml/efs-service-account.yaml.tpl")
  vars = {
    account_id = var.account_id
  }
}
resource "kubectl_manifest" "efs-service-account" {
  yaml_body = data.template_file.efs-service-account.rendered
}

# 6. Install the Amazon EFS driver 
data "template_file" "efs-csi-driver-values" {
  template = file("${path.module}/yml/efs-csi-driver-values.yaml")
}

resource "helm_release" "efs-csi-driver" {
  namespace        = "kube-system"
  create_namespace = false

  name       = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
  version    = "~> 2.4"

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/eks/aws-efs-csi-driver"
  }
  set {
    name  = "controller.serviceAccount.create"
    value = false
  }
  set {
    name  = "controller.serviceAccount.name"
    value = "efs-csi-controller-sa"
  }
  set {
    name  = "sidecars.livenessProbe.image.repository"
    value = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/eks/livenessprobe"
  }
  set {
    name  = "sidecars.nodeDriverRegistrar.image.repository"
    value = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/eks/csi-node-driver-registrar"
  }
  set {
    name  = "sidecars.csiProvisioner.image.repository"
    value = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/eks/csi-provisioner"
  }

  values = [
    data.template_file.efs-csi-driver-values.rendered
  ]

  depends_on = [
    module.eks
  ]
}

