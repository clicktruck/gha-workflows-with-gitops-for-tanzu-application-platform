data "aws_secretsmanager_secret" "vault" {
  name = var.secrets_manager_name
}

resource "aws_secretsmanager_secret_version" "vault_secrets" {
  secret_id     = data.aws_secretsmanager_secret.vault.arn
  secret_string = var.kv_secrets_map
}