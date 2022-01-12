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

resource "google_compute_router" "rs-route" {
  name    = "rs-gw-router"
  network = google_compute_network.rshiwalkar-vpc-network.self_link
  region  = var.region
}


module "google-cloud-nat-gw" {
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "1.4.0"
  router     = google_compute_router.rs-route.name
  project_id = var.project
  region     = var.region
  name       = "rs-cloud-nat-gw"
}

module "gce-lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 5.1"
  name    = "rs-cloud-lb"
  project = var.project
  target_tags = [
    "rshiwalkar-subnetwork",
    module.google-cloud-nat-gw.router_name
  ]
  firewall_networks = [google_compute_network.rshiwalkar-vpc-network.name]

  backends = {
    default = {

      description                     = null
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      enable_cdn                      = false
      security_policy                 = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null
      custom_response_headers         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/"
        port                = 80
        host                = null
        logging             = null
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group                        = google_compute_instance_group_manager.default.instance_group//module.mig1.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        }
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }
}

data "template_file" "group-startup-script" {
  template = file(format("%s/gceme.sh.tpl", path.module))

  vars = {
    PROXY_PATH = ""
  }
}

/*module "mig1_template" {
  source     = "terraform-google-modules/vm/google//modules/instance_template"
  version    = "6.2.0"
  network    = google_compute_network.rshiwalkar-vpc-network.self_link
  subnetwork = google_compute_subnetwork.rshiwalkar-vpc-subnetwork.self_link
  service_account = {
    email  = ""
    scopes = ["cloud-platform"]
  }
  //name_prefix          = "${var.network_prefix}-group1"
  startup_script       = data.template_file.group-startup-script.rendered
  source_image_family  = "ubuntu-1804-lts"
  source_image_project = "ubuntu-os-cloud"
  tags = [
    "rshiwalkar-subnetwork",
    module.google-cloud-nat-gw.router_name
  ]
}

module "mig1" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "6.2.0"
  instance_template = module.mig1_template.self_link
  region            = var.region
  //hostname          = "${var.network_prefix}-group1"
  target_size       = 2
  named_ports = [{
    name = "http",
    port = 80
  }]
  network    = google_compute_network.rshiwalkar-vpc-network.self_link
  subnetwork = google_compute_subnetwork.rshiwalkar-vpc-subnetwork.self_link
}*/

resource "google_compute_instance_template" "appserver-instance-template" {
  name        = "appserver-template"
  description = "This template is used to create app server instances."

  tags = [
    "rshiwalkar-subnetwork",
    module.google-cloud-nat-gw.router_name
  ]
  
  labels = {
    environment = "dev"
  }

  metadata_startup_script    = data.template_file.group-startup-script.rendered
  machine_type   = "e2-medium"
  can_ip_forward = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "debian-cloud/debian-9"
    auto_delete  = true
    boot         = true
    //resource_policies = [google_compute_resource_policy.daily_backup.id]
  }

  network_interface {
    network = google_compute_network.rshiwalkar-vpc-network.id
    access_config {
    }
    subnetwork = google_compute_subnetwork.rshiwalkar-vpc-subnetwork.id
  }
}

resource "google_compute_instance_group_manager" "default" {
  name     = "l7-xlb-mig1"
  //provider = google-beta
  zone     = "us-central1-c"
  named_port {
    name = "http"
    port = 80
  }
  version {
    instance_template = google_compute_instance_template.appserver-instance-template.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 2
}