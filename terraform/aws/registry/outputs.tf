data "aws_ecr_authorization_token" "token" {
  registry_id = aws_ecr_repository.ecr.registry_id
}

output "ecr_admin_username" {
  description = "The username associated with the Container Registry admin account"
  value       = data.aws_ecr_authorization_token.token.user_name
}

output "ecr_admin_password" {
  description = "The password associated with the Container Registry admin account"
  value       = data.aws_ecr_authorization_token.token.password
  sensitive   = true
}

output "ecr_endpoint" {
  description = "The URL that can be used to log into the container image registry (typically https://{aws_account_id}.dkr.ecr.{region}.amazonaws.com)."
  value       = data.aws_ecr_authorization_token.token.proxy_endpoint
}
