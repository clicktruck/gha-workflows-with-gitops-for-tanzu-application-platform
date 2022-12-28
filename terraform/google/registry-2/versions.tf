terraform {

  required_version = ">= 0.14.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.33.0"
    }
  }
}