variable "project" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  sensitive   = true
}

variable "location" {
  description = "The location of the registry. One of [ asia, eu, us ] or not specified."

  validation {
    condition     = contains(["asia", "eu", "us"], var.location)
    error_message = "Valid values for Google Cloud Container Registry locations are (asia, eu, us)."
  }

  default = "us"
}
