output "vpc_name" {
    value = google_compute_network.vpc-network.name
}

output "subnetwork_id" {
    value  = google_compute_subnetwork.vpc-subnetwork.id
}