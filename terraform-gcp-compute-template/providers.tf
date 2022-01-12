terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      //version = "4.5.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      //version = "3.90.1"
    }
  }
}

provider "google" {
  credentials = file("<path of key file>")

  project = "terraform-gcp-infra"
  region  = "us-central1"
  zone    = "us-central1-c"
}

provider "google-beta" {
  credentials = file("/home/ubuntu/gcp-key.json")
  project = "terraform-gcp-infra"
}