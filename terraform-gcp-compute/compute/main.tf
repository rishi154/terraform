resource "random_id" "rs_random_id" {
  count       = var.instance_count
  byte_length = 2
}

resource "google_compute_instance" "vm_instance" {
  count        = var.instance_count
  name         = "terraform-instance-${random_id.rs_random_id[count.index].dec}"
  machine_type = "e2-micro"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = var.vpc_name
    access_config {
    }
    subnetwork = var.subnet_name
  }
}
