output "vpc_network_name" {
  value = google_compute_network.vpc_network.name
}

output "subnet_ids" {
  value = { for subnet_key, subnet in google_compute_subnetwork.subnet : subnet_key => subnet.id }
}

output "vpc_network_id" {
  value = google_compute_network.vpc_network.id
}