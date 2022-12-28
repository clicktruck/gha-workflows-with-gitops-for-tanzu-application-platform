output "domain" {
  value = trim(aws_route53_zone.main.name, ".")
}

output "hosted_zone_id" {
  value = aws_route53_zone.main.zone_id
}

output "name_servers" {
  value = aws_route53_zone.main.name_servers
}