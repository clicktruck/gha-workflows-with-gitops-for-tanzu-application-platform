module "vcn" {
  source                       = "oracle-terraform-modules/vcn/oci"
  version                      = "3.5.2"
  compartment_id               = var.vcn_compartment_ocid
  region                       = var.region
  internet_gateway_route_rules = null
  local_peering_gateways       = null
  nat_gateway_route_rules      = null
  vcn_name                     = var.vcn_name
  vcn_dns_label                = replace(var.vcn_name, "-", "")
  vcn_cidrs                    = [var.vcn_cidr]
  create_internet_gateway      = true
  create_nat_gateway           = true
  create_service_gateway       = true
}

resource "oci_core_security_list" "private_subnet_sl" {
  compartment_id = var.vcn_compartment_ocid
  vcn_id         = module.vcn.vcn_id

  display_name = "${var.vcn_name}-private-subnet-sl"

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    stateless   = false
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }
}

resource "oci_core_security_list" "public_subnet_sl" {
  compartment_id = var.vcn_compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = "${var.vcn_name}-public-subnet-sl"
  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
  ingress_security_rules {
    stateless   = false
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }
  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 6443
      max = 6443
    }
  }
}

resource "oci_core_subnet" "vcn_private_subnet" {
  compartment_id = var.vcn_compartment_ocid
  vcn_id         = module.vcn.vcn_id
  cidr_block     = var.private_subnet_cidr

  route_table_id             = module.vcn.nat_route_id
  security_list_ids          = [oci_core_security_list.private_subnet_sl.id]
  display_name               = "${var.vcn_name}-private-subnet"
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "vcn_public_subnet" {
  compartment_id    = var.vcn_compartment_ocid
  vcn_id            = module.vcn.vcn_id
  cidr_block        = var.public_subnet_cidr
  route_table_id    = module.vcn.ig_route_id
  security_list_ids = [oci_core_security_list.public_subnet_sl.id]
  display_name      = "${var.vcn_name}-public-subnet"
}
