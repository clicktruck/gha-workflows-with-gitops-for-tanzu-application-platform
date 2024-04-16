resource "random_string" "suffix" {
  length  = 6
  special = false
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    ManagedBy              = "Terraform"
    GithubRepo             = "https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples/eks-cluster-with-new-vpc"
    ContributingGithubRepo = "https://github.com/clicktruck/gha-workflows-with-gitops-for-tanzu-application-platform"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "vpc-${random_string.suffix.result}"
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k + 12)]
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 2, k)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "vpc-${random_string.suffix.result}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "vpc-${random_string.suffix.result}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "vpc-${random_string.suffix.result}-default" }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

resource "aws_security_group" "provisioner" {
  name        = "provisioner-sg-${random_string.suffix.result}"
  description = "Allow SSH access to provisioner host and outbound internet access"
  vpc_id      = module.vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ssh" {
  protocol          = "TCP"
  from_port         = 22
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.provisioner.id
}

resource "aws_security_group_rule" "internet" {
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.provisioner.id
}
