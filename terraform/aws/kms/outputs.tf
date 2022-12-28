output "key_id" {
  value       = module.ssm.key_id
  description = "The globally unique identifier for the key."
}

output "key_arn" {
  value       = module.ssm.key_arn
  description = "The Amazon Resource Name (ARN) of the key."
}