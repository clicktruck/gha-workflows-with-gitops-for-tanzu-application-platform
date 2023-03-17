output "contents_of_kubeconfig" {
  value     = module.aks.kube_config_raw
  sensitive = true
}

output "latest_k8s_version" {
  value = data.azurerm_kubernetes_service_versions.current.*.latest_version
}

output "k8s_version_installed" {
  value = var.k8s_version
}

output "public_openssh_key" {
  value     = module.aks.generated_cluster_public_ssh_key
  sensitive = true
}

output "private_openssh_key" {
  value     = module.aks.generated_cluster_private_ssh_key
  sensitive = true
}

output "aks_cluster_name" {
  value = module.aks.aks_name
}
