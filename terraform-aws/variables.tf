# root variables.tf

variable "aws_region" {
  default = "us-west-2"
}

variable "access_ip" {}

# -- database variables ---

variable "dbname" {}

variable "dbuser" {
  sensitive = true
}

variable "dbpassword" {
  sensitive = true
}