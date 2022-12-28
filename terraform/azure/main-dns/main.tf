resource "azurerm_dns_zone" "main" {
  name = var.domain
  tags = {
    description = "Azure DNS managed zone for ${var.domain}"
  }
  resource_group_name = var.resource_group_name
}
