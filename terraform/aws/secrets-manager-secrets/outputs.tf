output "secrets_manager_secrets" {
  value     = jsondecode(aws_secretsmanager_secret_version.vault_secrets.secret_string)
  sensitive = true
}