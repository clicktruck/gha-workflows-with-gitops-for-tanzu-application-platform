provider "azurerm" {}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}
