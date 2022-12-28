output "vcn-ocid" {
  description = "OCID of the VCN that is created"
  value       = module.vcn.vcn_id
}

output "nat-gateway-ocid" {
  description = "OCID for NAT gateway"
  value       = module.vcn.nat_gateway_id
}

output "internet-gateway-id" {
  description = "OCID for Internet gateway"
  value       = module.vcn.internet_gateway_id
}

output "bastion-subnet-ocid" {
  description = "OCID for Bastion Host subnet"
  value       = oci_core_subnet.vcn_public_subnet.id
}

output "k8s-lb-subnet-ocid" {
  description = "OCID for Kubernetes LB subnet"
  value       = oci_core_subnet.vcn_public_subnet.id
}

output "k8s-api-endpoint-subnet-ocid" {
  description = "OCID for Kubernetes API endpoint subnet"
  value       = oci_core_subnet.vcn_public_subnet.id
}

output "k8s-node-pool-subnet-ocid" {
  description = "OCID for Kubernetes Node Pool subnet"
  value       = oci_core_subnet.vcn_private_subnet.id
}
