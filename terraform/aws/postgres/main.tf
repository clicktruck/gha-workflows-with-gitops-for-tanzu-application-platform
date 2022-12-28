locals {
  use_external_kms_key = length(var.kms_key_id) > 0 ? true : false
  region_settings_prefix      = "/${module.this.namespace}-${module.this.environment}-region-settings"
  region_settings_param_count = var.region_settings_params_enabled ? 1 : 0
}

resource "random_id" "suffix" {
  byte_length = 6
}

resource "random_string" "password" {
  length           = 16
  special          = false
}

# Create a RDS security group in the VPC which our database will belong to.
# It also wraps a local ansible execution to provision multiple databases in the postgres
# RDS instance, when var.provision_databases = true
module "kms_key_rds" {
  source = "git::https://github.com/cloudposse/terraform-aws-kms-key.git?ref=tags/0.12.1"

  count                   = local.use_external_kms_key ? 0 : 1
  description             = "KMS key for rds"
  deletion_window_in_days = 10
  enable_key_rotation     = "true"
  alias                   = "alias/${module.this.id}_kms_key"
  policy                  = var.kms_key_policy
}

resource "aws_security_group" "rds" {
  vpc_id = var.vpc_id

  # Keep the instance private by only allowing traffic from the web server.
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

module "db" {
  source                  = "terraform-aws-modules/rds/aws"
  version                 = "4.2.0"
  identifier              = "${var.database_username}-${random_id.suffix.hex}"
  engine                  = var.engine
  family                  = var.family
  engine_version          = var.engine_version
  major_engine_version    = var.major_engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  storage_encrypted       = true
  kms_key_id              = local.use_external_kms_key ? var.kms_key_id : module.kms_key_rds[0].key_arn
  name                    = "${var.database_username}-${random_id.suffix.hex}"
  username                = var.database_username
  password                = random_string.password.result
  port                    = "5432"
  subnet_ids              = var.subnet_ids
  vpc_security_group_ids  = [aws_security_group.rds.id]
  multi_az                = false
  maintenance_window      = var.maintenance_window
  backup_window           = var.backup_window
  backup_retention_period = var.backup_retention_period
  create_db_option_group  = false

  create_monitoring_role = true
  monitoring_interval    = var.monitoring_interval
  monitoring_role_name   = "AllowRDSMonitoringFor-${module.this.id}"

  # Snapshot name upon DB deletion
  final_snapshot_identifier   = "${module.this.id}-final-snapshot"
  deletion_protection         = var.deletion_protection_enabled
  skip_final_snapshot         = var.skip_final_snapshot
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately
  tags                        = var.tags
}

resource "aws_ssm_parameter" "db_admin_username" {
  count = local.region_settings_param_count
  name  = "${local.region_settings_prefix}/rds/db_admin_username"
  type  = "String"
  value = var.database_username
  tags  = var.tags
}

resource "aws_ssm_parameter" "db_port" {
  count = local.region_settings_param_count
  name  = "${local.region_settings_prefix}/rds/db_port"
  type  = "String"
  value = module.db.this_db_instance_port
  tags  = var.tags
}

resource "aws_ssm_parameter" "db_endpoint" {
  count = local.region_settings_param_count
  name  = "${local.region_settings_prefix}/rds/db_endpoint"
  type  = "String"
  value = module.db.this_db_instance_endpoint
  tags  = var.tags
}

resource "aws_ssm_parameter" "db_arn" {
  count = local.region_settings_param_count
  name  = "${local.region_settings_prefix}/rds/db_arn"
  type  = "String"
  value = module.db.this_db_instance_arn
  tags  = var.tags
}

resource "aws_ssm_parameter" "db_address" {
  count = local.region_settings_param_count
  name  = "${local.region_settings_prefix}/rds/db_address"
  type  = "String"
  value = module.db.this_db_instance_address
  tags  = var.tags
}
