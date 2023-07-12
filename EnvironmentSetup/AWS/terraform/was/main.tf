#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date:       jul-2023
#
# usage: create a Wolfram Application Service stack, consisting of the following:
#       - VPC
#       - EKS cluster + managed node group + EBS CSI Driver, CNI, kube-proxy, CoreDNS
#       - Kubernetes cert-manager
#       - Kubernetes Nginx ingress controller
#       - Kubernetes Minio
#       - Kubernetes Prometheus
#       - Kubernetes Strimzi operator for Kafka
#       - Kubernetes vertical pod autoscaler
#       - Wolfram Application Server for Kubernetes
#------------------------------------------------------------------------------

module "eks" {
  source = "../modules/eks"

  shared_resource_name = var.shared_resource_name

  account_id  = var.account_id
  aws_region  = var.aws_region
  aws_profile = var.aws_profile

  cidr                = var.cidr
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  namespace           = var.shared_resource_name
  cluster_version     = var.cluster_version
  disk_size           = var.disk_size
  instance_types      = var.instance_types
  desired_worker_node = var.desired_worker_node
  min_worker_node     = var.min_worker_node
  max_worker_node     = var.max_worker_node
  capacity_type       = var.capacity_type
  aws_auth_users      = var.aws_auth_users
  kms_key_owners      = var.kms_key_owners

}

# Strimzi is an operator that installs, configures and
# manages all Kafka resources on a near real-time basis
module "strimzi" {
  source = "../modules/kubernetes_strimzi"
  name   = var.shared_resource_name

  depends_on = [module.eks]
}

module "kafka" {
  source = "../modules/kubernetes_kafka"
  name   = var.shared_resource_name

  depends_on = [module.strimzi]
}

module "minio" {
  source = "../modules/kubernetes_minio"

  depends_on = [module.eks, module.metricsserver]
}

module "vpa" {
  source = "../modules/kubernetes_vpa"

  depends_on = [module.eks]
}

module "metricsserver" {
  source = "../modules/kubernetes_metricsserver"

  depends_on = [module.eks]
}

module "prometheus" {
  source = "../modules/kubernetes_prometheus"

  domain = "${var.shared_resource_name}.${var.root_domain}"

  depends_on = [module.eks, module.metricsserver]
}

module "ingress_controller" {
  source     = "../modules/kubernetes_ingress_controller"
  depends_on = [module.eks]
}

module "cert_manager" {
  source = "../modules/kubernetes_cert_manager"

  root_domain        = var.root_domain
  namespace          = var.shared_resource_name
  services_subdomain = var.services_subdomain
  aws_region         = var.aws_region

  depends_on = [module.eks]
}

module "was" {
  source = "../modules/kubernetes_was"

  shared_resource_name = var.shared_resource_name
  namespace            = var.shared_resource_name
  aws_region           = var.aws_region
  domain               = "${var.shared_resource_name}.${var.root_domain}"
  s3_bucket            = "${var.account_id}-${var.shared_resource_name}"
  tags                 = var.tags

  depends_on = [module.eks]
}
