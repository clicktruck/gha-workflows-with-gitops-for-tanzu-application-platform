output "ssh_key_name" {
  description = "Name of SSH key used for bastion host and cluster worker nodes"
  value       = module.ssh_key_pair.key_name
}

output "ssh_private_key_filename" {
  description = "Private Key Filename"
  value       = module.ssh_key_pair.private_key_filename
}

output "ssh_public_key_filename" {
  description = "Public Key Filename"
  value       = module.ssh_key_pair.public_key_filename
}

output "ssh_private_key" {
  description = "Content of the generated private key"
  value       = module.ssh_key_pair.private_key
  sensitive   = true
}

output "ssh_public_key" {
  description = "Content of the generated public key"
  value       = module.ssh_key_pair.public_key
  sensitive   = true
}
