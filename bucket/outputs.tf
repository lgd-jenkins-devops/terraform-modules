output "bucket_name" {
  value = var.bucket-type == "backend" ?  : google_storage_bucket.backend_bucket["enabled"].name :  google_storage_bucket.static-site["enabled"].name
}
