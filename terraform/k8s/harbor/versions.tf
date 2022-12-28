terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.5.1"
    }
    carvel = {
      source  = "vmware-tanzu/carvel"
      version = "0.11.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    random = {
      source = "hashicorp/random"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  required_version = ">= 0.14"
}
