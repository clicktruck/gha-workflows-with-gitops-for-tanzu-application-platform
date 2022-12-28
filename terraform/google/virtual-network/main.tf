
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_network_name
  auto_create_subnetworks = false
}


# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork
resource "google_compute_subnetwork" "subnetwork" {
  for_each = var.subnetworks
  provider = google-beta

  name          = each.key
  ip_cidr_range = each.value.cidr
  region        = var.vpc_subnetwork_region
  network       = google_compute_network.vpc_network.name

  # vms in this subnet can reach Google API
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = each.value.pods_cidr
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = each.value.services_cidr
  }

  # https://cloud.google.com/sdk/gcloud/reference/compute/networks/subnets/create#--purpose
  purpose = each.value.purpose
}

resource "google_compute_subnetwork" "https-lb-subnetwork" {
  provider = google-beta

  name          = "https-lb-only-subnet"
  ip_cidr_range = var.https_lb_only_subnet_cidr
  region        = var.vpc_subnetwork_region
  network       = google_compute_network.vpc_network.name
  role          = "ACTIVE"

  # https://cloud.google.com/sdk/gcloud/reference/compute/networks/subnets/create#--purpose
  purpose = "INTERNAL_HTTPS_LOAD_BALANCER" # internal HTTPS LB
  #purpose       = "REGIONAL_MANAGED_PROXY" # regional HTTPS LB
}


# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
resource "google_compute_firewall" "firewall-all-internal" {

  name      = "${google_compute_network.vpc_network.name}-allow-internal"
  network   = google_compute_network.vpc_network.name
  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = [var.firewall_internal_allow_cidr]
}

resource "google_compute_firewall" "firewall-allow-ssh" {

  name      = "${google_compute_network.vpc_network.name}-ext-ssh-allow"
  network   = google_compute_network.vpc_network.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["jumpbox"]
}

resource "google_compute_address" "internal_ip" {
  for_each = var.subnetworks
  name     = "${each.key}-int-ip"
  address  = cidrhost(each.value.cidr, 99)

  subnetwork   = google_compute_subnetwork.subnetwork[each.key].id
  region       = var.vpc_subnetwork_region
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
}

resource "google_compute_router" "nat-router" {
  name    = "${google_compute_network.vpc_network.name}-router1"
  network = google_compute_network.vpc_network.name
  region  = var.vpc_subnetwork_region
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat
resource "google_compute_router_nat" "nat-gateway" {
  name   = "${google_compute_network.vpc_network.name}-nat-gateway1"
  router = google_compute_router.nat-router.name
  region = google_compute_router.nat-router.region

  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # if LIST_OF_SUBNETWORKS were defined above, then you must provide list
  #subnetwork {
  #   name = google_compute_subnetwork.private_subnetwork.id
  #   source_ip_ranges_to_nat = [ var.private_cidr_block ] # "ALL_IP_RANGES"
  #}
}
