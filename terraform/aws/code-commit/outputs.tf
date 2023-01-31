output "code_commit_repository_id" {
  description = "The ID of the AWS Code Commit repository"
  value       = aws_codecommit_repository.this.repository_id
}

output "code_commit_arn" {
  description = "The ARN of the AWS Code Commit repository"
  value       = aws_codecommit_repository.this.arn
}

output "code_commit_clone_url_http" {
  description = "The URL to use for cloning the AWS Code Commit repository over HTTPS"
  value       = aws_codecommit_repository.this.clone_url_http
}

output "code_commit_clone_url_ssh" {
  description = "The URL to use for cloning the AWS Code Commit repository over SSH"
  value       = aws_codecommit_repository.this.clone_url_ssh
}
