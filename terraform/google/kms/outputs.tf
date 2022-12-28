output "keyring_name" {
  value       = google_kms_key_ring.key_ring.name
  description = "Name of the keyring"
}
