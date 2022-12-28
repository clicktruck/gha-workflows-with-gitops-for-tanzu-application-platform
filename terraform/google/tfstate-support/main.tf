resource "random_string" "suffix" {
  length  = 6
  special = false
}

data "google_kms_key_ring" "terraform" {
  count    = length(var.keyring) > 0 ? 1 : 0
  name     = var.keyring
  location = var.location
}

data "google_kms_crypto_key" "terraform" {
  count    = length(var.keyring) > 0 ? 1 : 0
  name     = "terraform"
  key_ring = data.google_kms_key_ring.terraform[count.index].id
}

data "google_storage_project_service_account" "gcs_account" {
  count = length(var.keyring) > 0 ? 1 : 0
}

// Crypto IAM binding to use recent key ring and key
resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  count         = length(var.keyring) > 0 ? 1 : 0
  crypto_key_id = data.google_kms_crypto_key.terraform[count.index].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account[count.index].email_address}"]
}

resource "google_storage_bucket" "cmek_terraform_state" {
  count         = length(var.keyring) > 0 ? 1 : 0
  name          = join("-", [var.bucket_name, "tfstate", lower(random_string.suffix.result)])
  location      = upper(var.location)
  force_destroy = true

  encryption {
    default_kms_key_name = data.google_kms_crypto_key.terraform[count.index].id
  }

  versioning {
    enabled = true
  }

  # Ensure the KMS crypto-key IAM binding for the service account exists prior to the
  # bucket attempting to utilize the crypto-key.
  depends_on = [google_kms_crypto_key_iam_binding.crypto_key]
}

resource "google_storage_bucket" "terraform_state" {
  count         = length(var.keyring) == 0 ? 1 : 0
  name          = join("-", [var.bucket_name, "tfstate", lower(random_string.suffix.result)])
  location      = upper(var.location)
  force_destroy = true

  versioning {
    enabled = true
  }
}