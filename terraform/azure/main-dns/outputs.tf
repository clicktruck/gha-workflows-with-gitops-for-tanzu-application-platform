output "zone_domain" {
  value = azurerm_dns_zone.main.name
}

output "zone_domain_ns_records" {
  value = azurerm_dns_zone.main.name_servers
}