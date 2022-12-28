variable "description" {
  type        = string
  description = "The description of the key as viewed in AWS console."
  default     = "KMS key for System Manager"
}

variable "key_spec" {
  type        = string
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1"
  default     = "SYMMETRIC_DEFAULT"
}

variable "enabled" {
  type        = bool
  description = "Specifies whether the key is enabled."
  default     = true
}

variable "rotation_enabled" {
  type        = bool
  description = "Specifies whether key rotation is enabled."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assigned to the key."
  default = {
    Name  = "ssm"
    Owner = "bootcamp-admin"
  }
}

variable "alias" {
  type        = string
  description = "The display name of the key."
  default     = "ssm"
}

variable "admin_username" {
  type        = string
  description = "KMS administrator user name."
}

variable "assign_policy" {
  type        = bool
  description = "Whether or not to assign an aws_iam_policy_document, in the form that designates a principal. Defaults to false."
  default     = false
}