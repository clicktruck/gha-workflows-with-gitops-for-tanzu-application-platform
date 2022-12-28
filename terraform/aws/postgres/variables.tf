variable "vpc_cidr_block" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_username" {
  type = string
  default = "admin"
}

variable "instance_class" {
  type = string
  default = "db.m5.xlarge"
}

variable "engine" {
  type = string
  default = "postgres"
}

variable "engine_version" {
  type = string
  default = "14.2"
}

variable "major_engine_version" {
  type = string
  default = "14.2"
}

variable "allocated_storage" {
  type = number
  default = 20
}

variable "family" {
  type = string
  default = "postgres14"
}


variable "subnet_ids" {
  type = list(string)
}

variable "deletion_protection_enabled" {
  type = bool
  default = false
}

variable "skip_final_snapshot" {
  type = bool
  default = true
}

variable "allow_major_version_upgrade" {
  type = bool
  default = false
}

variable "apply_immediately" {
  type = bool
  default = false
}

variable "backup_retention_period" {
  type = number
}

variable "maintenance_window" {
  type    = string
  default = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
  type    = string
  default = "03:00-06:00"
}

variable "monitoring_interval" {
  type    = string
  default = "60"
}

variable "region_settings_params_enabled" {
  type        = bool
  description = "When enabled the connection information (except password) is stored in SSM Param Store region settings for this deployment"
  default     = true
}

variable "kms_key_id" {
  type        = string
  description = "An optional KMS key to use to encrypt the database, if not provided, one will be generated."
  default     = ""
}

variable "kms_key_policy" {
  type        = string
  description = "A valid policy JSON document to be appplied to the kms key created by this module. Not necessary if supplying your own kms key."
  default     = ""
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}
