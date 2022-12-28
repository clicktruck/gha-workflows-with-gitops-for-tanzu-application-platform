variable "repository_names" {
  type        = list(string)
  description = "Specifies the names of repositories that will be created within an Elastic Container Registry"
  default     = ["tanzu/build-service", "tanzu/supply-chain"]
}
