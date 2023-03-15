resource "kubernetes_annotations" "disk_default_storage" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "default"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
  force = true
}

resource "kubernetes_annotations" "blob_default_storage" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "azureblob-nfs-premium"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "true"
  }
  force = true
}

