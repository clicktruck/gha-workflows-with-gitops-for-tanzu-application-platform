output "admin_username" {
  value = "_json_key_base64"
}

output "admin_password" {
  description = "The base64-encoded password associated with the Container Registry admin account"
  value       = base64encode(data.external.env.result["google_service_account_key"])
  sensitive   = true
}

output "endpoint" {
  value = "${var.location}-docker.pkg.dev"
}