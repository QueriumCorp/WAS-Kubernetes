#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: jul-2023
#
# usage: minio module outputs
#------------------------------------------------------------------------------
output "helm_release_id" {
  description = "The ID of the minio"
  value       = helm_release.minio.id
}

output "helm_release_name" {
  description = "The name of the minio"
  value       = helm_release.minio.name
}

output "helm_release_namespace" {
  description = "The namespace of the minio"
  value       = helm_release.minio.namespace
}

output "helm_release_chart" {
  description = "The chart used to deploy minio"
  value       = helm_release.minio.chart
}

output "helm_release_repository" {
  description = "The repository used to deploy minio"
  value       = helm_release.minio.repository
}
