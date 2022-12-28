output "harbor_domain" {
  value = local.harbor_domain
}

output "harbor_admin_username" {
  value = "admin"
}

output "harbor_admin_password" {
  description = "The base64-encoded password associated with the Container Registry admin account"
  value       = base64encode(random_password.admin_password.result)
  sensitive   = true
}