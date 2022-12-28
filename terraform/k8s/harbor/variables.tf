variable "domain" {
  description = "The base domain wherein harbor.<domain> will be deployed"
}

variable "acme_email" {
  description = "A valid email address that will be used by Let's Encrypt via the ACME protocol to verify that you control a given domain name"
  type        = string
}

variable "kubeconfig_path" {
  description = "The path to your .kube/config"
  default     = "~/.kube/config"
}
