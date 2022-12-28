provider "google" {
  project = var.project
}

variable "project" {
  description = "The target active Google project id"
}
