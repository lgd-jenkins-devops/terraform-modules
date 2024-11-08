resource "google_service_account" "vm_service_account" {
  account_id   = var.account_id
  display_name = var.display_name
}

resource "google_project_iam_member" "vm_service_account_role" {
  project = var.project_id
  role    = var.role
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}

