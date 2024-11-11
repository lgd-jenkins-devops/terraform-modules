
locals {
  random_name = "${var.name}-${var.project_id}"
}

resource "google_storage_bucket" "static-site" {
  for_each = var.bucket-type == "static"  ? { "enabled" = "true" } : {}
  name          = local.random_name
  location      = var.location
  force_destroy = true

  uniform_bucket_level_access = true

  website {
    main_page_suffix = var.web_config.main
    not_found_page   = var.web_config.error
  }
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket_iam_member" "public_access" {
  for_each = var.bucket-type == "static"  ? { "enabled" = "true" } : {}
  bucket = google_storage_bucket.static-site["enabled"].name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket" "backend_bucket" {
  for_each = var.bucket-type == "backend"  ? { "enabled" = "true" } : {}
  name     = local.random_name
  location = var.location
}