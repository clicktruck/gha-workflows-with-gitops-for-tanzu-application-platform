output "latest_cluster_master_node_version" {
  value = data.google_container_engine_versions.cluster_versions.latest_master_version
}

output "latest_cluster_worker_node_verison" {
  value = data.google_container_engine_versions.cluster_versions.latest_node_version
}

output "default_cluster_node_version" {
  value = data.google_container_engine_versions.cluster_versions.default_cluster_version
}

output "release_channel_default_cluster_node_version" {
  value = data.google_container_engine_versions.cluster_versions.release_channel_default_version
}