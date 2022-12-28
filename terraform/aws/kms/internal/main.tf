# Creates/manages KMS CMK
resource "aws_kms_key" "this" {
  description              = var.description
  customer_master_key_spec = var.key_spec
  is_enabled               = var.enabled
  enable_key_rotation      = var.rotation_enabled
  tags                     = var.tags
  policy                   = var.policy
  deletion_window_in_days  = 30
}

resource "aws_kms_alias" "this" {
  name          = var.alias
  target_key_id = aws_kms_key.this.key_id
}
