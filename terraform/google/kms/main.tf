resource "random_string" "suffix" {
  length  = 6
  special = false
}

data "google_project" "metadata" {}

data "google_service_account" "svcaccount" {
  account_id = var.service_account_name
}

resource "google_kms_key_ring" "key_ring" {
  name     = length(var.keyring) > 0 ? var.keyring : join("-", ["keyring", lower(random_string.suffix.result)])
  project  = var.project
  location = var.location
}

resource "google_kms_crypto_key" "key" {
  name            = "terraform"
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = var.key_rotation_period
  purpose         = var.purpose

  lifecycle {
    prevent_destroy = true
  }

  version_template {
    algorithm        = var.key_algorithm
    protection_level = var.key_protection_level
  }

  labels = var.labels
}

resource "google_kms_crypto_key_iam_binding" "owners" {
  role          = "roles/owner"
  crypto_key_id = google_kms_crypto_key.key.id
  members = [
    "serviceAccount:${data.google_service_account.svcaccount.email}"
  ]
}

resource "google_kms_crypto_key_iam_binding" "decrypters" {
  role          = "roles/cloudkms.cryptoKeyDecrypter"
  crypto_key_id = google_kms_crypto_key.key.id
  members = [
    "serviceAccount:service-${data.google_project.metadata.number}@gcp-sa-secretmanager.iam.gserviceaccount.com",
    "serviceAccount:service-${data.google_project.metadata.number}@gcp-sa-artifactregistry.iam.gserviceaccount.com"
  ]
}

resource "google_kms_crypto_key_iam_binding" "encrypters" {
  role          = "roles/cloudkms.cryptoKeyEncrypter"
  crypto_key_id = google_kms_crypto_key.key.id
  members = [
    "serviceAccount:service-${data.google_project.metadata.number}@gcp-sa-secretmanager.iam.gserviceaccount.com",
    "serviceAccount:service-${data.google_project.metadata.number}@gcp-sa-artifactregistry.iam.gserviceaccount.com"
  ]
}
