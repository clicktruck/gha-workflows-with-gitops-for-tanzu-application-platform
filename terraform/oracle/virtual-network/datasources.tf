# Based upon https://github.com/oracle-devrel/terraform-oci-arch-oke/blob/main/examples/oke-public-lb-and-api-endpoint-private-workers-use-existing-network/datasources.tf

data "oci_containerengine_cluster_option" "oci_oke_cluster_option" {
  cluster_option_id = "all"
}

data "oci_containerengine_node_pool_option" "oci_oke_node_pool_option" {
  node_pool_option_id = "all"
}

data "oci_core_services" "AllOCIServices" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}
