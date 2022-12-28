resource "google_project_service_identity" "sm_sa" {
  provider = google-beta
  project  = var.project
  service  = "secretmanager.googleapis.com"
}

resource "google_project_service_identity" "ar_sa" {
  provider = google-beta
  project  = var.project
  service  = "artifactregistry.googleapis.com"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "svcaccount" {
  account_id   = var.service_account_name
  display_name = length(var.service_account_display) < 1 ? var.service_account_name : var.service_account_display
}


# GCP service accounts have eventual consistency
# wait a bit before applying IAM roles
# https://github.com/hashicorp/terraform/issues/17726#issuecomment-377357866
resource "null_resource" "delay" {

  provisioner "local-exec" {
    command = "sleep 60"
  }
  triggers = {
    "svcaccount" = google_service_account.svcaccount.id
  }

}

# use non-authoritative resource
# others in the same role are untouched
#
resource "google_project_iam_member" "svcaccount_roles" {
  project  = var.project
  for_each = toset(var.service_account_roles)
  role     = each.key

  member = "serviceAccount:${google_service_account.svcaccount.email}"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_key
# for downloading service account key
# even if service account resource is imported, this key resource cannot be imported, therefore a new key will be created and downloaded
resource "google_service_account_key" "svcaccount_key" {
  service_account_id = google_service_account.svcaccount.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "null_resource" "write_json" {

  provisioner "local-exec" {
    # private_key attribute is in base64 format
    command     = "echo ${google_service_account_key.svcaccount_key.private_key} | base64 -d > ${google_service_account.svcaccount.email}.json"
    working_dir = pathexpand(var.ssh_directory)
    on_failure  = continue
  }

}

resource "null_resource" "destroy_json" {
  triggers = {
    "secret_filename" = google_service_account.svcaccount.email
    "ssh_directory"   = var.ssh_directory
  }

  # deletes local json secret
  provisioner "local-exec" {
    when        = destroy
    command     = "rm -f ${self.triggers.secret_filename}.json"
    working_dir = pathexpand(self.triggers.ssh_directory)
    on_failure  = continue
  }
}