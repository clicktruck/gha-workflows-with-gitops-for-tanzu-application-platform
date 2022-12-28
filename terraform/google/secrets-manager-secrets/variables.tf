variable "project" {
  sensitive = true
}

variable "secret_manager_instance_name" {}

variable "secrets_key_value_map" {
  description = "Secret key-value map stored as a JSON string"
}
