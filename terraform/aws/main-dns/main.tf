resource "aws_route53_zone" "main" {
  name          = var.domain
  force_destroy = true
}
