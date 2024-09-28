module "networking" {
  max_subnets      = 3
  source           = "./networking"
  vpc_cidr         = local.vpc_cidr
  public_cidrs     = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_cidrs    = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_sn_count = 3
  public_sn_count  = 3
}

module "compute" {
  source           = "./compute"
  public_sg           = module.networking.public_sg
  public_subnets      = module.networking.public_subnets
  instance_count      = 1
  instance_type       = "t3.xlarge" #t3.micro"
  #vol_size            = 10
  key_name            = "newrskey"
  public_key_path     = "C:\\Users\\rishi\\Downloads\\rskey.pub"
}

output "compute_module" {  
  value = module.compute  
}