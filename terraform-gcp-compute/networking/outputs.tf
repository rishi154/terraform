output "vpc_name" {
    value = google_compute_network.rshiwalkar-vpc-network.name
}

output "subnetwork_id" {
    value  = google_compute_subnetwork.rshiwalkar-vpc-subnetwork.id
}