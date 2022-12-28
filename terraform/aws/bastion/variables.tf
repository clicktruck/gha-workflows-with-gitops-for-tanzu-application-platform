variable "ssh_key_name" {
  type        = string
  description = "The name of an SSH keypair"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID of a pre-existing public subnet within a VPC"
}

variable "provisioner_security_group_id" {
  type        = string
  description = "The security group id of a public subnet that will host bastion"
}

variable "eks_cluster_security_group_id" {
  type        = string
  description = "The security group id of a private subnet that will host cluster"
}

variable "vm_size" {
  type        = string
  description = "The EC2 instance type and size for the bastion"
  default     = "m5a.large"
}

variable "toolset_ami_owner" {
  type        = string
  description = "The owner of the toolset AMI"
}

variable "toolset_ami_name" {
  type        = string
  description = "The name of the AMI (without the timestamp or version suffix)"
  default     = "k8s-toolset-image"
}
