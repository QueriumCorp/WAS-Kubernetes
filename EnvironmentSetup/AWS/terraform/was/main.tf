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

  root_domain          = var.domain
  domain               = "${var.shared_resource_name}.${var.domain}"
  shared_resource_name = var.shared_resource_name
  account_id           = var.account_id
  aws_region           = var.aws_region
  aws_profile          = var.aws_profile
  azs                  = var.azs
  cidr                 = var.cidr
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
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
  service_nodegroup    = var.service_nodegroup
}

module "vpa" {
  source = "../modules/kubernetes_vpa"
  service_nodegroup    = var.service_nodegroup

  depends_on = [module.eks]
}

module "cert_manager" {
  source = "../modules/kubernetes_cert_manager"

  domain            = "${var.shared_resource_name}.${var.domain}"
  namespace         = var.shared_resource_name
  aws_region        = var.aws_region
  service_nodegroup = var.service_nodegroup

  depends_on = [module.eks]

}

module "metricsserver" {
  source = "../modules/kubernetes_metricsserver"

  service_nodegroup    = var.service_nodegroup

  depends_on = [module.eks]
}


module "prometheus" {
  source = "../modules/kubernetes_prometheus"

  domain            = "${var.shared_resource_name}.${var.domain}"
  cluster_issuer    = "${var.shared_resource_name}.${var.domain}"
  service_nodegroup = var.service_nodegroup

  depends_on = [module.eks, module.metricsserver]
}

module "ingress_controller" {
  source = "../modules/kubernetes_ingress_controller"

  domain            = "${var.shared_resource_name}.${var.domain}"
  service_nodegroup = var.service_nodegroup

  depends_on = [module.eks]
}


# Strimzi is an operator that installs, configures and
# manages all Kafka resources on a near real-time basis
module "strimzi" {
  source = "../modules/kubernetes_strimzi"

  name              = var.shared_resource_name
  service_nodegroup = var.service_nodegroup

  depends_on = [
    module.eks
  ]
}

module "kafka" {
  source = "../modules/kubernetes_kafka"
  name   = var.shared_resource_name

  depends_on = [module.strimzi]
}

module "kafka_topics" {
  source = "../modules/kubernetes_kafka_topics"
  name   = var.shared_resource_name

  depends_on = [module.strimzi]
}


module "minio" {
  source = "../modules/kubernetes_minio"

  shared_resource_name        = var.shared_resource_name
  minio_host                  = "minio.${var.domain}"
  tenantPoolsServers          = var.tenantPoolsServers
  tenantPoolsVolumesPerServer = var.tenantPoolsVolumesPerServer
  tenantPoolsSize             = var.tenantPoolsSize
  tenantPoolsStorageClassName = var.tenantPoolsStorageClassName

  depends_on = [module.eks, module.strimzi]
}


module "was" {
  source = "../modules/kubernetes_was"

  aws_region = var.aws_region

  shared_resource_name = var.shared_resource_name
  namespace            = var.shared_resource_name
  domain               = "${var.shared_resource_name}.${var.domain}"
  cluster_issuer       = "${var.shared_resource_name}.${var.domain}"
  s3_bucket            = "${var.account_id}-${var.shared_resource_name}"
  tags                 = var.tags

  was_active_web_elements_server_version = var.was_active_web_elements_server_version
  was_endpoint_manager_version           = var.was_endpoint_manager_version
  was_resource_manager_version           = var.was_resource_manager_version

  depends_on = [module.eks, module.minio]
}
