
locals {
  random_name = "${var.name}-${var.project_id}"
}

resource "google_storage_bucket" "static-site" {
  name          = local.random_name
  location      = var.location
  force_destroy = true

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket_iam_member" "public_access" {
  bucket = google_storage_bucket.static-site.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}