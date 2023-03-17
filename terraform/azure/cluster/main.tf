data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "aks_vnet" {
  name                = "vnet-${var.suffix}"
  resource_group_name = data.azurerm_resource_group.rg.name
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

data "azurerm_application_gateway" "gw" {
  name                = var.ingress_application_gateway_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "random_string" "prefix" {
  length  = 4
  special = false
  numeric = false
}


module "aks" {
  source = "github.com/Azure/terraform-azurerm-aks?ref=6.7.1"

  cluster_name                         = var.cluster_name
  cluster_log_analytics_workspace_name = var.cluster_name
  private_cluster_enabled              = false

  client_id     = var.client_id
  client_secret = var.client_secret

  prefix              = random_string.prefix.result
  resource_group_name = data.azurerm_resource_group.rg.name
  kubernetes_version  = var.k8s_version

  agents_availability_zones = ["1", "2"]
  agents_count              = null
  agents_max_count          = var.aks_nodes * 2
  agents_max_pods           = 100
  agents_min_count          = var.aks_nodes
  agents_pool_name          = replace("${var.cluster_name}np", "-", "")
  agents_pool_linux_os_configs = [
    {
      transparent_huge_page_enabled = "always"
      sysctl_configs = [{
        fs_aio_max_nr               = 65536
        fs_file_max                 = 100000
        fs_inotify_max_user_watches = 1000000
      }]
    }
  ]
  agents_size = var.aks_node_type
  agents_type = "VirtualMachineScaleSets"
  agents_tags = {
    environment = var.environment
  }

  azure_policy_enabled                = true
  disk_encryption_set_id              = azurerm_disk_encryption_set.des.id
  enable_auto_scaling                 = true
  enable_host_encryption              = false
  http_application_routing_enabled    = false
  ingress_application_gateway_enabled = true
  ingress_application_gateway_id      = data.azurerm_application_gateway.gw.id
  local_account_disabled              = false
  log_analytics_workspace_enabled     = true
  maintenance_window = {
    allowed = [
      {
        day   = "Sunday",
        hours = [22, 23]
      },
    ]
    not_allowed = [
      {
        start = "2035-01-01T20:00:00Z",
        end   = "2035-01-01T21:00:00Z"
      },
    ]
  }
  net_profile_dns_service_ip     = "10.0.0.10"
  net_profile_docker_bridge_cidr = "170.10.0.1/16"
  net_profile_service_cidr       = "10.0.0.0/16"
  network_plugin                 = "azure"
  network_policy                 = "azure"
  os_disk_size_gb                = var.aks_node_disk_size
  sku_tier                       = "Paid"

  storage_profile_enabled                     = true
  storage_profile_blob_driver_enabled         = true
  storage_profile_disk_driver_enabled         = true
  storage_profile_file_driver_enabled         = true
  storage_profile_snapshot_controller_enabled = true

  api_server_authorized_ip_ranges = var.k8s_api_server_authorized_ip_ranges
  vnet_subnet_id                  = data.azurerm_subnet.aks_subnet.id
}
