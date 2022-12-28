terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.96.0"
    }
  }
  required_version = ">= 0.14"
}