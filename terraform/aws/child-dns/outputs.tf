output "base_domain" {
  value = trim(aws_route53_zone.child.name, ".")
}

output "hosted_zone_id" {
  value = aws_route53_zone.child.zone_id
}

output "child_domain" {
  value = "${var.domain_prefix}.${data.aws_route53_zone.main.name}"
}
