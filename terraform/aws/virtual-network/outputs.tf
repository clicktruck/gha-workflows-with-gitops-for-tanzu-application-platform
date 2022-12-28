output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = join(",", module.vpc.public_subnets)
}

output "private_subnet_ids" {
  value = join(",", module.vpc.private_subnets)
}

output "private_subnets_cidr_blocks" {
  value = join(",", module.vpc.private_subnets_cidr_blocks)
}

output "public_subnets_cidr_blocks" {
  value = join(",", module.vpc.public_subnets_cidr_blocks)
}

output "provisioner_security_group_id" {
  value = aws_security_group.provisioner.id
}

output "vpc_endpoint_security_group_id" {
  value = module.vpc.default_security_group_id
}

output "a_public_subnet_id" {
  value = module.vpc.public_subnets[1]
}
