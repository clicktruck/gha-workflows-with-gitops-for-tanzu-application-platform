variable "repository_names" {
  type        = list(string)
  description = "Specifies the names of repositories that will be created within an Elastic Container Registry"
  default     = ["tap-images", "tap-build-service", "tanzu-application-platform"]
}
