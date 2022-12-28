variable "bucket_name" {
  type        = string
  description = "A valid Amazon S3 bucket name; see https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html"
  default     = "tap"
}

variable "alias" {
  type        = string
  description = "The display name of the key."
  default     = "alias/ssm"
}