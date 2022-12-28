output "mybilling" {
  value = data.google_billing_account.acct.id
}

output "projnumber" {
  value = google_project.project.number
}
