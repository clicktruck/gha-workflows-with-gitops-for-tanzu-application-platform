# Based upon https://github.com/oracle-devrel/terraform-oci-arch-oke/blob/main/examples/oke-public-lb-and-api-endpoint-private-workers-use-existing-network/network.tf

resource "oci_core_vcn" "vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "${var.vcn_name}_vcn"
}

resource "oci_core_service_gateway" "sg" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.vcn_name}_sg"
  vcn_id         = oci_core_vcn.vcn.id
  services {
    service_id = lookup(data.oci_core_services.AllOCIServices.services[0], "id")
  }
}

resource "oci_core_nat_gateway" "natgw" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.vcn_name}_natgw"
  vcn_id         = oci_core_vcn.vcn.id
}

resource "oci_core_route_table" "rt_via_natgw_and_sg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_name}_rt_via_natgw"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.natgw.id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.AllOCIServices.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sg.id
  }
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.vcn_name}_igw"
  vcn_id         = oci_core_vcn.vcn.id
}

resource "oci_core_route_table" "rt_via_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_name}_rt_via_igw"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}


resource "oci_core_security_list" "api_endpoint_subnet_sec_list" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.vcn_name}_api_endpoint_subnet_sec_list"
  vcn_id         = oci_core_vcn.vcn.id

  # egress_security_rules

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.nodepool_subnet_cidr
  }

  egress_security_rules {
    protocol         = 1
    destination_type = "CIDR_BLOCK"
    destination      = var.nodepool_subnet_cidr

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = lookup(data.oci_core_services.AllOCIServices.services[0], "cidr_block")

    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.nodepool_subnet_cidr

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.nodepool_subnet_cidr

    tcp_options {
      min = 12250
      max = 12250
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol = 1
    source   = var.nodepool_subnet_cidr

    icmp_options {
      type = 3
      code = 4
    }
  }

}

resource "oci_core_security_list" "nodepool_subnet_sec_list" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.vcn_name}_nodepool_subnet_sec_list"
  vcn_id         = oci_core_vcn.vcn.id

  egress_security_rules {
    protocol         = "All"
    destination_type = "CIDR_BLOCK"
    destination      = var.nodepool_subnet_cidr
  }

  egress_security_rules {
    protocol    = 1
    destination = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = lookup(data.oci_core_services.AllOCIServices.services[0], "cidr_block")
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.api_endpoint_subnet_cidr

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.api_endpoint_subnet_cidr

    tcp_options {
      min = 12250
      max = 12250
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "All"
    source   = var.nodepool_subnet_cidr
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.api_endpoint_subnet_cidr
  }

  ingress_security_rules {
    protocol = 1
    source   = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }
  }

}

resource "oci_core_subnet" "api_endpoint_subnet" {
  cidr_block        = var.api_endpoint_subnet_cidr
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.vcn.id
  display_name      = "${var.vcn_name}_api_endpoint_subnet"
  security_list_ids = [oci_core_vcn.vcn.default_security_list_id, oci_core_security_list.api_endpoint_subnet_sec_list.id]
  route_table_id    = oci_core_route_table.rt_via_igw.id
}

resource "oci_core_subnet" "lb_subnet" {
  cidr_block     = var.lb_subnet_cidr
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_name}_lb_subnet"

  security_list_ids = [oci_core_vcn.vcn.default_security_list_id]
  route_table_id    = oci_core_route_table.rt_via_igw.id
}

resource "oci_core_subnet" "nodepool_subnet" {
  cidr_block     = var.nodepool_subnet_cidr
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_name}_nodepool_subnet"

  security_list_ids          = [oci_core_vcn.vcn.default_security_list_id, oci_core_security_list.nodepool_subnet_sec_list.id]
  route_table_id             = oci_core_route_table.rt_via_natgw_and_sg.id
  prohibit_public_ip_on_vnic = true
}



