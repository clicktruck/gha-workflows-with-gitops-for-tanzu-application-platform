

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.46.0"
    }
  }
  required_version = ">= 0.14"
}