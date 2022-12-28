data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

output "public_subnets_cidr_block" {
  value = join(",", [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k + 12)])
}

output "private_subnets_cidr_block" {
  value = join(",", [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 2, k)])
}

output "vpc_cidr" {
  value = var.vpc_cidr
}