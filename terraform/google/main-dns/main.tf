locals {
  domain_parts = split(".", var.root_domain)
}

resource "google_dns_managed_zone" "zone" {
  name          = join("-", [local.domain_parts[0], "zone"])
  dns_name      = "${var.root_domain}."
  description   = "Google DNS managed zone for ${var.root_domain}"
  force_destroy = true
}
