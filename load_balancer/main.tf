### backend GCE

resource "google_compute_instance_group" "default" {
  for_each = var.type == "http" || var.type == "https" ? { "enabled" = "true" } : {}

  name        = "instance-group"
  zone        = var.zone
  network     = var.network
  instances   = [
    var.jenkins_id
  ]
  
  named_port {
    name = "http"
    port = "8080"
  }

}

# Crear un Health Check para el balanceador de carga
resource "google_compute_health_check" "default" {
  for_each = var.type == "http" || var.type == "https" ? { "enabled" = "true" } : {}
  name               = "http-health-check"

  check_interval_sec = 5
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 2
  tcp_health_check {
    port = "8080"
  }
}

resource "google_compute_backend_service" "default" {
  for_each = var.type == "http" || var.type == "https" ? { "enabled" = "true" } : {}
  name            = "backend-service"
  backend {
    group = google_compute_instance_group.default["enabled"].self_link
  }
  health_checks = [google_compute_health_check.default["enabled"].self_link]
  protocol      = "HTTP"
  port_name     = "http"
}



#### Backend bucket

resource "google_compute_backend_bucket" "static_content_backend" {
  for_each = var.type == "http-bucket" || var.type == "https-bucket" ? { "enabled" = "true" } : {}
  name             = "static-website-backend"
  bucket_name      = var.bucket_name
  enable_cdn       = false
}


#### http config
# HTTP target proxy
resource "google_compute_target_http_proxy" "default" {
  for_each = var.type == "http" || var.type == "http-bucket" ? { "enabled" = "true" } : {}
  name     = "l7-gilb-target-http-proxy"
  provider = google
  url_map  = google_compute_url_map.default.id
}

#### https config

resource "google_compute_ssl_certificate" "default" {
  for_each = var.type == "https" || var.type == "https-bucket" ? { "enabled" = "true" } : {}
  name_prefix = "my-certificate-"
  private_key = file(var.path_key)
  certificate = file(var.path_cert)

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_target_https_proxy" "default" {
  for_each = var.type == "https" || var.type == "https-bucket" ? { "enabled" = "true" } : {}
  name             = "test-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_ssl_certificate.default["enabled"].id]
}


#### General config
# Crear el URL Map
resource "google_compute_url_map" "default" {
  name            = "url-map"
  default_service =  var.type == "https" || var.type == "http" ? google_compute_backend_service.default["enabled"].self_link : google_compute_backend_bucket.static_content_backend["enabled"].id
}




# Reglas de Reenvío (Frontend)
resource "google_compute_global_forwarding_rule" "default" {
  name       = "http-forwarding-rule"
  provider              = google
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range = var.type == "https" || var.type == "https-bucket" ? "443" : "80"
  target     = var.type == "https" || var.type == "https-bucket" ? google_compute_target_https_proxy.default["enabled"].self_link : google_compute_target_http_proxy.default["enabled"].self_link
  ip_address = google_compute_global_address.default.address
}

# Dirección IP Global
resource "google_compute_global_address" "default" {
  name = "global-ip"
}