locals {
  k8s_version = var.k8s_version != null && contains(data.azurerm_kubernetes_service_versions.current.versions, var.k8s_version) ? var.k8s_version : data.azurerm_kubernetes_service_versions.current.latest_version
  # We cannot use coalesce here because it's not short-circuit and public_ip's index will cause error
  public_ip = jsondecode(data.curl.public_ip.response).ip
}
