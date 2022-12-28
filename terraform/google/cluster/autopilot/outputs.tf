output "cluster_name" {
  value       = google_container_cluster.apcluster.name
  description = "GKE Autopilot Cluster Name"
}

output "path_to_kubeconfig" {
  value = "${var.kubeconfig_directory}/kubeconfig-${var.cluster_name}"
}
