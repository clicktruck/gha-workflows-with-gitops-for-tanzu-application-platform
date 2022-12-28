resource "oci_dns_zone" "zone" {
  compartment_id = var.compartment_ocid
  name           = var.root_zone_name
  zone_type      = "PRIMARY"
}
