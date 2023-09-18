module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.32.1"

  eks_cluster_id       = var.eks_cluster_id
  eks_cluster_endpoint = var.eks_cluster_endpoint
  eks_oidc_provider    = var.oidc_provider
  eks_cluster_version  = var.eks_cluster_version

  # EKS Managed Add-ons
  enable_amazon_eks_coredns            = true
  enable_amazon_eks_kube_proxy         = true
  enable_amazon_eks_aws_ebs_csi_driver = true

  # User managed Add-ons
  enable_aws_cloudwatch_metrics       = true
  enable_aws_load_balancer_controller = true
  enable_crossplane                   = true
  crossplane_aws_provider             = local.crossplane_aws_provider
  crossplane_helm_config              = local.crossplane_helm_config
  enable_kyverno                      = true
  enable_kyverno_policies             = false
  enable_kyverno_policy_reporter      = true
  enable_metrics_server               = true

  tags = local.tags
}
