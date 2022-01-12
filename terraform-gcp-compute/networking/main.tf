resource "google_compute_network" "rshiwalkar-vpc-network" {
  name                    = "rshiwalkar-vpc"
  auto_create_subnetworks = false

}

resource "google_compute_subnetwork" "rshiwalkar-vpc-subnetwork" {
  name          = "rshiwalkar-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.rshiwalkar-vpc-network.id
}