resource "random_id" "suffix" {
  byte_length = 6
}

data "aws_kms_alias" "ssm" {
  name = var.alias
}

resource "aws_secretsmanager_secret" "vault" {
  name                    = "secrets-manager-${random_id.suffix.hex}"
  kms_key_id              = data.aws_kms_alias.ssm.target_key_id
  recovery_window_in_days = 0
}
