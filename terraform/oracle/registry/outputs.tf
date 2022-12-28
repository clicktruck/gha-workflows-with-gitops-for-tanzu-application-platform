output "admin_username" {
  description = "The username associated with the Container Registry admin account"
  value       = "${var.tenancy_ocid}/oracleidentitycloudservice/${var.email_address}"
  sensitive   = true
}

output "admin_password" {
  description = "The base64-encoded password associated with the Container Registry admin account"
  value       = base64encode(oci_identity_auth_token.auth_token.token)
  sensitive   = true
}

output "endpoint" {
  value = "${var.region}.ocir.io"
}