variable "kv_secrets_map" {
  description = "Key-value map of secrets (in JSON format)"
  default     = "{}"
}

variable "secrets_manager_name" {
  type        = string
  description = "The name of an AWS Secrets Manager instance"
}