resource "random_string" "suffix" {
  length  = 6
  special = false
}

data "aws_kms_alias" "bucket_key" {
  name = var.alias
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = join("-", [var.bucket_name, "tfstate", lower(random_string.suffix.result)])
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = data.aws_kms_alias.bucket_key.target_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_state" {
  name           = join("-", [var.bucket_name, "tfstate", lower(random_string.suffix.result)])
  read_capacity  = 50
  write_capacity = 50
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
