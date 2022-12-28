resource "oci_dns_zone" "zone" {
  compartment_id = var.compartment_ocid
  name           = "${var.dns_prefix}.${var.root_zone_name}"
  zone_type      = "PRIMARY"
}

resource "oci_dns_rrset" "ns_record" {
  domain          = oci_dns_zone.zone.name
  rtype           = "NS"
  zone_name_or_id = var.root_zone_name
  compartment_id  = var.compartment_ocid
}