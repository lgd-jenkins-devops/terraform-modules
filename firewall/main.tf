resource "google_compute_firewall" "allow-rule" {

  for_each = var.rules

  name    = each.value.name
  network = var.network

  allow {
    protocol = each.value.protocol
    ports    = each.value.ports
  }

  target_tags  = each.value.tags

  source_ranges = each.value.type == "external" ? each.value.range : []

  
}
