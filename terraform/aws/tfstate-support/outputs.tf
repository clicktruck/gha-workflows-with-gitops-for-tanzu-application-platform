output "provisioned_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "provisioned_dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_state.name
}