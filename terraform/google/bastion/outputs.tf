# will only have value if public
output "public_ip" {
  value = var.has_public_ip ? google_compute_instance.vm.network_interface.0.access_config.0.nat_ip : ""
}

output "internal_ip" {
  value = google_compute_instance.vm.network_interface.0.network_ip
}

output "to_ssh_to_bastion" {
  value = "gcloud compute ssh --zone \"${var.zone}\" \"${var.vm_name}\"  --project \"${var.project}\""
}
