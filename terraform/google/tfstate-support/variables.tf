variable "project" {
  sensitive = true
}

variable "bucket_name" {
  type        = string
  description = "A valid Google Cloud Storage bucket name; see https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html"
  default     = "tap"
}

variable "location" {
  type        = string
  description = "Google Cloud Storage bucket and Google Cloud KMS keyring locations"

  validation {
    condition     = contains(["us-west1", "us-west2", "us-east1", "us-central1", "europe-north1", "europe-west1", "europe-southwest1", "asia-east1", "asia-south1", "asia-northeast3", "australia-southeast2"], var.location)
    error_message = "Valid values for Google Cloud Storage bucket and Google Cloud KMS keyring locations are (us-west1, us-west2, us-east1, us-central1, europe-north1, europe-west1, europe-southwest1, asia-east1, asia-south1, asia-northeast3, australia-southeast2)."
  }

  default = "us-west2"
}

variable "keyring" { default = "" }
