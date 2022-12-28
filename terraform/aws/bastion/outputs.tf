output "to_ssh_to_bastion" {
  value = join(" ", ["ssh", "-o 'IdentitiesOnly yes'", "-i", pathexpand("~/.ssh/${var.ssh_key_name}.pem"), "-v", "ubuntu@${aws_eip.provisioner.public_ip}"])
}
