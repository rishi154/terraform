terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}

provider "google" {
  credentials = file("<Key File>")
  project = "<Project ID>"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_network" "rshiwalkar-vpc-network" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "rshiwalkar-vpc-subnetwork" {
  name          = "rshiwalkar-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.rshiwalkar-vpc-network.id
}

variable "gke_num_nodes" {
  default     = 1  
}

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.project}-gke"
  location = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  node_locations = ["us-central1-a", "us-central1-b","us-central1-c"]
  network    = google_compute_network.rshiwalkar-vpc-network.name
  subnetwork = google_compute_subnetwork.rshiwalkar-vpc-subnetwork.name
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project
    }

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}




variable "network_name" {
    default = "rshiwalkar-vpc"
}

variable "region" {
    default = "us-central1"
}

variable "project" {
    default = "<Project ID>"
}

