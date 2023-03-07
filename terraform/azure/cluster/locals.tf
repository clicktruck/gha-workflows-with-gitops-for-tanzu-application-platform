locals {
  k8s_version = var.k8s_version != null && contains(data.azurerm_kubernetes_service_versions.current.versions, var.k8s_version) ? var.k8s_version : data.azurerm_kubernetes_service_versions.current.latest_version
}
