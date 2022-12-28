data "external" "env" {
  program = ["${path.module}/env.sh"]
}

data "google_kms_key_ring" "terraform" {
  name     = var.keyring
  location = var.location
}

data "google_kms_crypto_key" "terraform" {
  name     = "terraform"
  key_ring = data.google_kms_key_ring.terraform.id
}

resource "google_artifact_registry_repository" "instance" {
  for_each      = toset(var.repository_names)
  location      = var.location
  kms_key_name  = data.google_kms_crypto_key.terraform.id
  repository_id = each.key
  description   = "OCI image repository"
  format        = "DOCKER"
}
