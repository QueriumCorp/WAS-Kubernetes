# need this bc the default aws profile specifies us-east-2

module "vpc" {
  source = "../modules/vpc"

  shared_resource_name = var.shared_resource_name
  account_id           = var.account_id
  aws_region           = var.aws_region
  aws_profile          = var.aws_profile
  cidr                 = var.cidr
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
}

module "eks" {
  source = "../modules/eks"
  
  shared_resource_name = var.shared_resource_name
  account_id           = var.account_id
  aws_region           = var.aws_region
  aws_profile          = var.aws_profile
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnets
  namespace            = var.shared_resource_name
  cluster_version      = var.cluster_version
  disk_size            = var.disk_size
  instance_types       = var.instance_types
  desired_worker_node  = var.desired_worker_node
  min_worker_node      = var.min_worker_node
  max_worker_node      = var.max_worker_node
  capacity_type        = var.capacity_type
  aws_auth_users       = var.aws_auth_users
  kms_key_owners       = var.kms_key_owners

  depends_on = [module.vpc]
}

module "vpa" {
  source     = "../modules/kubernetes_vpa"
  depends_on = [module.vpc, module.eks]
}

module "metricsserver" {
  source     = "../modules/kubernetes_metricsserver"
  depends_on = [module.vpc, module.eks, module.vpa]
}

module "prometheus" {
  source     = "../modules/kubernetes_prometheus"
  depends_on = [module.eks, module.metricsserver, module.vpa]
}

module "ingress_controller" {
  source     = "../modules/kubernetes_ingress_controller"
  depends_on = [module.vpc, module.eks, module.vpa]
}

module "cert_manager" {
  source     = "../modules/kubernetes_cert_manager"

  root_domain         = var.root_domain
  namespace           = var.shared_resource_name
  services_subdomain  = var.services_subdomain

  depends_on = [module.vpc, module.eks, module.vpa, module.module.ingress_controller]
}

module "minio" {
  source     = "../modules/kubernetes_minio"
  namespace   = var.shared_resource_name
  ingress_hostname = "minio.${var.services_subdomain}"
  depends_on = [module.eks, module.metricsserver, module.vpa, module.ingress_controller]
}

module "kafka" {
  source     = "../modules/kubernetes_kafka"
  depends_on = [module.eks, module.metricsserver, module.vpa, module.ingress_controller]
}