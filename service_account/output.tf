output "service_account_email" {
  value = google_service_account.vm_service_account.email
}

output "service_account_id" {
  value = google_service_account.vm_service_account.id
}