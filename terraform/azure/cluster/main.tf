data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet-${var.suffix}"
  virtual_network_name = "vnet-${var.suffix}"
  resource_group_name  = data.azurerm_resource_group.rg.name
}

# Documentation Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_service_versions
# Datasource to get Latest Azure AKS latest Version
data "azurerm_kubernetes_service_versions" "current" {
  location        = data.azurerm_resource_group.rg.location
  include_preview = false
}

resource "random_string" "prefix" {
  length  = 4
  special = false
  numeric = false
}


module "aks" {
  source = "github.com/Azure/terraform-azurerm-aks?ref=6.7.0"

  orchestrator_version = var.k8s_version

  prefix                               = random_string.prefix.result
  resource_group_name                  = data.azurerm_resource_group.rg.name
  azure_policy_enabled                 = true
  cluster_log_analytics_workspace_name = var.cluster_name
  cluster_name                         = var.cluster_name
  disk_encryption_set_id               = azurerm_disk_encryption_set.des.id
  log_analytics_workspace_enabled      = true

  maintenance_window = {
    allowed = [
      {
        day   = "Sunday",
        hours = [22, 23]
      },
    ]
    not_allowed = []
  }

  vnet_subnet_id = data.azurerm_subnet.aks_subnet.id

  rbac_aad                          = true
  rbac_aad_managed                  = true
  role_based_access_control_enabled = true

  agents_size      = var.aks_node_type
  agents_min_count = var.aks_nodes
  agents_tags = {
    environment = var.environment
  }

  os_disk_size_gb = var.aks_node_disk_size

  api_server_authorized_ip_ranges = var.k8s_api_server_authorized_ip_ranges

}
