output "provisioned_bucket_name" {
  value = length(var.keyring) > 0 ? join("", google_storage_bucket.cmek_terraform_state.*.name) : join("", google_storage_bucket.terraform_state.*.name)
}

output "provisioned_bucket_url" {
  value = length(var.keyring) > 0 ? join("", google_storage_bucket.cmek_terraform_state.*.url) : join("", google_storage_bucket.terraform_state.*.url)
}