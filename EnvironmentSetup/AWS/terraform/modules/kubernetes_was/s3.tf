
module "was_s3_storage" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.14"

  bucket                    = var.s3_bucket
  acl                       = "private"
  tags                      = var.tags
  control_object_ownership  = true
  object_ownership          = "BucketOwnerPreferred"
  attach_policy             = true
  policy                    = data.aws_iam_policy_document.bucket_policy.json

  cors_rule = [
    {
      allowed_methods = ["GET", "POST", "PUT", "HEAD"]
      allowed_origins = [
        "https://${var.domain}",
        "http://${var.domain}"
      ]
      allowed_headers = ["*"]
      expose_headers = [
        "Access-Control-Allow-Origin",
        "Access-Control-Allow-Method",
        "Access-Control-Allow-Header"
      ]
      max_age_seconds = 3000
    }
  ]
  versioning = {
    enabled = false
  }
}

###############################################################################
#                           SUPPORTING RESOURCES
###############################################################################


data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions = [
      "s3:GetObject*",
      "s3:List*",
    ]
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    resources = [
      "${module.was_s3_storage.s3_bucket_arn}/*"
    ]
  }
}

# Generate an additional IAM user with read-only access to the bucket
resource "random_id" "id" {
  byte_length = 16
}

resource "aws_iam_user" "was_s3_storage_user" {
  name = "s3-openedx-user-${random_id.id.hex}"
  path = "/system/s3-bucket-user/"
  tags = {}
}


resource "kubernetes_secret" "was_s3" {
  metadata {
    name      = "${var.shared_resource_name}-s3"
    namespace = var.shared_resource_name
  }

  data = {
    AWS_ACCESS_KEY        = aws_iam_access_key.was_s3_storage_user.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.was_s3_storage_user.secret
    S3_STORAGE_BUCKET     = module.was_s3_storage.s3_bucket_id
  }
}

data "aws_iam_policy_document" "user_policy" {
  statement {
    actions = [
      "s3:*"
    ]
    resources = [
      module.was_s3_storage.s3_bucket_arn
    ]
  }
  statement {
    actions = [
      "s3:*"
    ]
    resources = [
      "${module.was_s3_storage.s3_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_access_key" "was_s3_storage_user" {
  user = aws_iam_user.was_s3_storage_user.name
}

resource "aws_iam_user_policy" "policy" {
  name   = "${var.shared_resource_name}-s3-bucket"
  policy = data.aws_iam_policy_document.user_policy.json
  user   = aws_iam_user.was_s3_storage_user.name
}