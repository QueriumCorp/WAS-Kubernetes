terraform {
  backend "s3" {
    bucket         = "320713933456-terraform-tfstate-was-01"
    key            = "kubernetes_prometheus/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking-was2"
    profile        = "default"
    encrypt        = false
  }
}
