variable "project" {
  sensitive = true
}

variable "keyring" { default = "" }

variable "location" {
  type        = string
  description = "Google Cloud KMS keyring location"

  validation {
    condition     = contains(["us-west1", "us-west2", "us-east1", "us-central1", "europe-north1", "europe-west1", "europe-southwest1", "asia-east1", "asia-south1", "asia-northeast3", "australia-southeast2"], var.location)
    error_message = "Valid values for Google Cloud KMS keyring location are (us-west1, us-west2, us-east1, us-central1, europe-north1, europe-west1, europe-southwest1, asia-east1, asia-south1, asia-northeast3, australia-southeast2)."
  }

  default = "us-west2"
}

variable "service_account_name" { default = "terraform" }

variable "prevent_destroy" {
  description = "Set the prevent_destroy lifecycle attribute on keys."
  default     = true
}

variable "purpose" {
  type        = string
  description = "The immutable purpose of the CryptoKey. Possible values are ENCRYPT_DECRYPT, ASYMMETRIC_SIGN, and ASYMMETRIC_DECRYPT."
  default     = "ENCRYPT_DECRYPT"
}

variable "key_rotation_period" {
  type    = string
  default = "100000s"
}

variable "key_algorithm" {
  type        = string
  description = "The algorithm to use when creating a version based on this template. See the https://cloud.google.com/kms/docs/reference/rest/v1/CryptoKeyVersionAlgorithm for possible inputs."
  default     = "GOOGLE_SYMMETRIC_ENCRYPTION"
}

variable "key_protection_level" {
  type        = string
  description = "The protection level to use when creating a version based on this template. Default value: \"SOFTWARE\" Possible values: [\"SOFTWARE\", \"HSM\"]"
  default     = "SOFTWARE"
}

variable "labels" {
  type        = map(string)
  description = "Labels, provided as a map"
  default     = {}
}
