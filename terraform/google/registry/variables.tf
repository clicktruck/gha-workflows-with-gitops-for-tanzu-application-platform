variable "project" {
  sensitive = true
}

variable "repository_names" {
  type        = list(string)
  description = "Specifies the names of repositories that will be created within Google Cloud Artifact Registry"
  default     = ["tanzu"]
}

variable "location" {
  type        = string
  description = "Google Cloud Artifact Registry Repository and Google Cloud KMS keyring locations"

  validation {
    condition     = contains(["us-west1", "us-west2", "us-east1", "us-central1", "europe-north1", "europe-west1", "europe-southwest1", "asia-east1", "asia-south1", "asia-northeast3", "australia-southeast2"], var.location)
    error_message = "Valid values for Google Cloud Artifact Registry locations are (us-west1, us-west2, us-east1, us-central1, europe-north1, europe-west1, europe-southwest1, asia-east1, asia-south1, asia-northeast3, australia-southeast2)."
  }

  default = "us-west2"
}

variable "keyring" {}