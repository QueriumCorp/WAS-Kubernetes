#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Jul-2023
#
# Create the Amazon EFS CSI driver IAM role for service accounts
# https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html
#------------------------------------------------------------------------------

resource "aws_iam_policy" "AmazonEKS_EFS_CSI_Driver_Policy" {
  name = "AmazonEKS_EFS_CSI_Driver_Policy"
  description = "WAS EFS Policy"

  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:DescribeAccessPoints",
        "elasticfilesystem:DescribeFileSystems",
        "elasticfilesystem:DescribeMountTargets",
        "ec2:DescribeAvailabilityZones"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:CreateAccessPoint"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:RequestTag/efs.csi.aws.com/cluster": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:TagResource"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:ResourceTag/efs.csi.aws.com/cluster": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "elasticfilesystem:DeleteAccessPoint",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/efs.csi.aws.com/cluster": "true"
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
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.account_id}:oidc-provider/oidc.eks.${var.aws_region}.amazonaws.com/id/D166659358A4D92DFF5FD0B97C0E2899"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.${var.aws_region}.amazonaws.com/id/D166659358A4D92DFF5FD0B97C0E2899:sub": "system:serviceaccount:kube-system:efs-csi-controller-sa"
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
    account_id          = var.account_id
  }
}
resource "kubectl_manifest" "efs-service-account" {
  yaml_body  = data.template_file.efs-service-account.rendered
}



# 6. Restart the ebs-csi-controller deployment for the annotation to take effect
resource "null_resource" "annotate-ebs-csi-controller" {

  provisioner "local-exec" {
    command = <<-EOT
      # 1. configure kubeconfig locally with the credentials data of the just-created
      # kubernetes cluster.
      # ---------------------------------------
      aws eks --region ${var.aws_region} update-kubeconfig --name ${var.shared_resource_name} --alias ${var.shared_resource_name}
      kubectl config use-context ${var.shared_resource_name}
      kubectl config set-context --current --namespace=kube-system

      # 2. final install steps for EBS CSI Driver
      # ---------------------------------------
      kubectl annotate serviceaccount ebs-csi-controller-sa -n kube-system eks.amazonaws.com/role-arn=arn:aws:iam::${var.account_id}:role/${aws_iam_role.AmazonEKS_EFS_CSI_DriverRoleWAS.name}
      kubectl rollout restart deployment ebs-csi-controller -n kube-system
    EOT
  }

  depends_on = [
    module.eks
  ]
}
