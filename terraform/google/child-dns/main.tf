data "google_dns_managed_zone" "root_zone" {
  name = var.root_domain_zone_name
}

resource "google_dns_managed_zone" "zone" {
  name          = "${var.subdomain}-${data.google_dns_managed_zone.root_zone.name}"
  dns_name      = "${var.subdomain}.${data.google_dns_managed_zone.root_zone.dns_name}"
  description   = "Google DNS managed zone for ${var.subdomain}.${data.google_dns_managed_zone.root_zone.dns_name}"
  force_destroy = true
}

resource "google_dns_record_set" "ns_record" {
  managed_zone = data.google_dns_managed_zone.root_zone.name
  name         = "${var.subdomain}.${data.google_dns_managed_zone.root_zone.dns_name}"
  rrdatas      = google_dns_managed_zone.zone.name_servers

  ttl  = 30
  type = "NS"
}
