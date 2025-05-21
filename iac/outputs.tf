output "cluster_name" {
  value = module.eks.cluster_name
}

output "region" {
  value = var.region
}

output "kubeconfig" {
  description = "Kubeconfig output"
  value       = module.eks.kubeconfig_filename
}
