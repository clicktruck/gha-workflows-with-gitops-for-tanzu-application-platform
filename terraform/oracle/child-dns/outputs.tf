output "zone_subdomain" {
  value = trim(oci_dns_zone.zone.name, ".")
}