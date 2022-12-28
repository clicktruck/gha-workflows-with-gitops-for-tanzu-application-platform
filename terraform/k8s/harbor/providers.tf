provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

provider "carvel" {
  kapp {
    diff_output_file = "kapp.diff.log"
    kubeconfig {
      from_env = true
    }
  }
}

