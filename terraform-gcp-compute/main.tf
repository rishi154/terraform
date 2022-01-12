module "compute" {
  source         = "./compute"
  instance_count = 2
  vpc_name = module.networking.vpc_name
  subnetwork_id = module.networking.subnetwork_id
}

module "networking" {
  source = "./networking"
}