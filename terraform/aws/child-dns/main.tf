data "aws_route53_zone" "main" {
  name = var.base_domain
}

resource "aws_route53_zone" "child" {
  name          = "${var.domain_prefix}.${data.aws_route53_zone.main.name}"
  force_destroy = true
}

resource "aws_route53_record" "main_ns_additions" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = aws_route53_zone.child.name
  type    = "NS"
  ttl     = "30"

  records = aws_route53_zone.child.name_servers
}