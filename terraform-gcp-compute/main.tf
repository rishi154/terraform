module "compute" {
  source         = "./compute"
  instance_count = 1
  vpc_name = module.networking.vpc_name
  #subnetwork_id = module.networking.subnetwork_id
  subnet_name = var.subnet_name
}

module "networking" {
  source = "./networking"
  vpc_name = var.vpc_name
  subnet_name = var.subnet_name
  ip_cidr_range = var.ip_cidr_range
  region = var.region
}