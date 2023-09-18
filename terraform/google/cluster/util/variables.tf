variable "project" {
  sensitive = true
}
variable "region" {}

# terraform says repair+upgrade must be true when REGULAR
variable "cluster_version_prefix" { default = "1.26" }
variable "cluster_release_channel" { default = "RAPID" }
