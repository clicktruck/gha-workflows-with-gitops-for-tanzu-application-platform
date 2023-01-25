output "gcr_bucket_id" {
  description = "The name of the bucket that supports the Container Registry"
  value       = google_container_registry.reg.id
}

output "gcr_repository_url" {
  description = "The URL at which the repository can be accessed"
  value       = data.google_container_registry_repository.repo.repository_url
}

output "admin_username" {
  value = "_json_key_base64"
}

output "admin_password" {
  description = "The base64-encoded password associated with the Container Registry admin account"
  value       = base64encode(data.external.env.result["google_service_account_key"])
  sensitive   = true
}

output "endpoint" {
  value = "${var.location}.gcr.io"
}
