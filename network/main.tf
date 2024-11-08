resource "google_compute_network" "vpc_network" {
  project                 = var.project_id
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

locals {
  subnet_names = {
    for subnet_key, subnet in var.subnets : 
    subnet_key => "${subnet_key}-${var.region}"
  }
}

resource "google_compute_subnetwork" "subnet" {

  for_each = var.subnets

  name          = local.subnet_names[each.key]
  ip_cidr_range = each.value.cidr_block
  region        = var.region
  network       = google_compute_network.vpc_network.id

}

