data "google_secret_manager_secret" "instance" {
  secret_id = var.secret_manager_instance_name
}

resource "google_secret_manager_secret_version" "secrets" {
  secret      = data.google_secret_manager_secret.instance.id
  secret_data = var.secrets_key_value_map
}
