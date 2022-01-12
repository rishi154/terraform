terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.5.0"
    }
  }
}

provider "google" {
  credentials = file("<Path of key file>")

  project = "terraform-gcp-infra"
  region  = "us-central1"
  zone    = "us-central1-c"
}
