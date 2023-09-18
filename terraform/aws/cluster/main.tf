resource "random_string" "suffix" {
  length  = 6
  special = false
}

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.32.1"

  cluster_name    = "${var.eks_cluster_id}-${random_string.suffix.result}"
  cluster_version = var.kubernetes_version

  eks_readiness_timeout = 900

  vpc_id             = var.vpc_id
  private_subnet_ids = local.private_subnet_id_array

  managed_node_groups = {
    on_demand = {
      node_group_name       = "managed-ondemand"
      instance_types        = [var.node_pool_instance_type]
      min_size              = local.min_worker_nodes
      max_size              = local.max_worker_nodes
      desired_size          = var.desired_nodes
      subnet_ids            = local.private_subnet_id_array
      remote_access         = true
      ec2_ssh_key           = var.ssh_key_name
      ssh_security_group_id = [var.provisioner_security_group_id]
    }
  }

  tags = local.tags
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}
