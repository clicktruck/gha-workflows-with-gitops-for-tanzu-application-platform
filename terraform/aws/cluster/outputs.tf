output "eks_cluster_id" {
  description = "The name of the EKS cluster"
  value       = module.eks_blueprints.eks_cluster_id
}

output "eks_cluster_arn" {
  description = "Amazon EKS Cluster Name"
  value       = module.eks_blueprints.eks_cluster_arn
}

output "eks_cluster_security_group_id" {
  description = "EKS created security group ID applied to ENI that is attached to EKS Control Plane master nodes"
  value       = module.eks_blueprints.cluster_security_group_id
}

output "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks_blueprints.eks_cluster_endpoint
}

output "eks_cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = module.eks_blueprints.eks_cluster_version
}

output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = module.eks_blueprints.oidc_provider
}

output "to_obtain_kubeconfig" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}
