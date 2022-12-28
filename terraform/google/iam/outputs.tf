output "svcaccount_json" {
  sensitive = true
  value     = base64decode(google_service_account_key.svcaccount_key.private_key)
}

output "secret_manager_service_identity" {
  value = google_project_service_identity.sm_sa.email
}

output "artifact_registry_service_identity" {
  value = google_project_service_identity.ar_sa.email
}