variable "eks_cluster_id" {
  type        = string
  description = "Name of this EKS cluster"
}

variable "vpc_id" {
  type        = string
  description = "An identifier of an existing AWS VPC"
}

variable "desired_nodes" {
  type        = number
  description = "Desired number of worker nodes"
  default     = 3
}

variable "kubernetes_version" {
  type        = string
  description = "Supported Kubernetes major.minor version"
  default     = "1.26"
}

variable "ssh_key_name" {}

variable "node_pool_instance_type" {
  type    = string
  default = "m5a.xlarge"
}

variable "provisioner_security_group_id" {
  type = string
}

variable "private_subnet_ids" {
  type        = string
  description = "Comma-separated string of private subnet identifiers"
}

variable "public_subnet_ids" {
  type        = string
  description = "Comma-separated string of public subnet identifiers"
}

variable "kubeconfig_path" {
  description = "The path to your .kube/config"
  default     = "~/.kube/config"
}
