output "secrets_manager_arn" {
  value = aws_secretsmanager_secret.vault.arn
}

output "secrets_manager_name" {
  value = aws_secretsmanager_secret.vault.name
}
