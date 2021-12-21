terraform {
  backend "remote" {
    organization = "rshiwalkar-terraform"

    workspaces {
      name = "rshiwalkar-dev"
    }
  }
}