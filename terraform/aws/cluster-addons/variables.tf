variable "eks_cluster_id" {
  type        = string
  description = "The name of an EKS cluster that will have add-ons installed"
}

variable "eks_cluster_endpoint" {
  type        = string
  description = "Endpoint for your Kubernetes API server"
}

variable "eks_cluster_version" {
  type        = string
  description = "The Kubernetes version for the cluster"
}

variable "oidc_provider" {
  type        = string
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
}

variable "kubeconfig_path" {
  description = "The path to your .kube/config"
  default     = "~/.kube/config"
}