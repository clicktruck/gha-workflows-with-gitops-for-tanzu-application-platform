data "google_kms_key_ring" "terraform" {
  name     = var.keyring
  location = var.location
}

data "google_kms_crypto_key" "terraform" {
  name     = "terraform"
  key_ring = data.google_kms_key_ring.terraform.id
}

resource "google_secret_manager_secret" "instance" {
  secret_id = var.secret_manager_instance_name

  replication {
    user_managed {
      replicas {
        location = var.location
        customer_managed_encryption {
          kms_key_name = data.google_kms_crypto_key.terraform.id
        }
      }
    }
  }
}
