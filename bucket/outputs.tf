output "bucket_name" {
  value = google_storage_bucket.static-site["enabled"].name
}
