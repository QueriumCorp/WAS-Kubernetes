output "account_id" {
  value = local.account_id  
}
output "aws_auth_users" {
  value = local.aws_auth_users
}
output "aws_region" {
  value = local.aws_region  
}
output "capacity_type" {
  value = local.capacity_type
}
output "cidr" {
  value = local.cidr
}
output "cluster_name" {
  value = local.cluster_name
}
output "cluster_version" {
  value = local.cluster_version
} 
output "kms_key_owners" {
  value = local.kms_key_owners
}
output "private_subnets" {
  value = local.private_subnets
}
output "public_subnets" {
  value = local.public_subnets
}

output "namdesired_worker_nodee" {
  value = local.desired_worker_node
}
output "max_worker_node" {
  value = local.max_worker_node  
}
output "min_worker_node" {
  value = local.min_worker_node
}
output "disk_size" {
  value = local.disk_size
}
output "instance_types" {
  value = local.instance_types
}
