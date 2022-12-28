output "cluster_name" {
  value       = google_container_cluster.cluster.name
  description = "GKE Cluster Name"
}

output "path_to_kubeconfig" {
  value = "${var.kubeconfig_directory}/kubeconfig-${var.cluster_name}"
}
