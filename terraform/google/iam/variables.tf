variable "project" {
  sensitive = true
}

variable "service_account_name" { default = "terraform" }

# email used if not overriden
variable "service_account_display" { default = "Deploys IaC with Terraform" }

variable "service_account_roles" {
  type = list(string)
  default = [
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/storage.admin",
    "roles/compute.securityAdmin",
    "roles/compute.instanceAdmin",
    "roles/compute.instanceAdmin.v1",
    "roles/compute.networkAdmin",
    "roles/dns.admin",
    "roles/iam.serviceAccountUser",
    "roles/pubsub.editor",
    "roles/gkehub.admin",
    "roles/meshconfig.admin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/servicemanagement.admin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/privateca.admin",
    "roles/container.admin",
    "roles/container.clusterAdmin",
    "roles/container.developer",
    "roles/iam.workloadIdentityUser",
    "roles/cloudsql.admin",
    "roles/cloudkms.admin",
    "roles/cloudkms.cryptoKeyEncrypterDecrypter",
    "roles/secretmanager.admin",
    "roles/artifactregistry.admin"
  ]
}

variable "ssh_directory" {
  default = "~/.ssh"
}
