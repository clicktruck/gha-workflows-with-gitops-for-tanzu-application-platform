variable "project" {
  sensitive = true
}

variable "keyring" {}

variable "secret_manager_instance_name" {}

variable "location" {
  type        = string
  description = "Google Cloud secret manager instance replication and Google Cloud KMS keyring locations"

  validation {
    condition     = contains(["us-west1", "us-west2", "us-east1", "us-central1", "europe-north1", "europe-west1", "europe-southwest1", "asia-east1", "asia-south1", "asia-northeast3", "australia-southeast2"], var.location)
    error_message = "Valid values for Google Cloud secret manager instance replication and Google Cloud KMS keyring locations are (us-west1, us-west2, us-east1, us-central1, europe-north1, europe-west1, europe-southwest1, asia-east1, asia-south1, asia-northeast3, australia-southeast2)."
  }

  default = "us-west2"
}
