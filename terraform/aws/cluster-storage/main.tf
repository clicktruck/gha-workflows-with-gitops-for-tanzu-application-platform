resource "kubernetes_annotations" "existing_default_storage" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
  force = true
}

resource "kubernetes_manifest" "new_default_storage" {
  manifest = yamldecode(file("${path.module}/gp3-def-sc.yaml"))
}
