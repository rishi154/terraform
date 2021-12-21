data "aws_availability_zones" "available" {}

resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}


resource "aws_vpc" "rshiwalkar_jenkins_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "rshiwalkar_jenkins_vpc-${random_integer.random.id}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "rshiwalkar_jenkins_public_subnet" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.rshiwalkar_jenkins_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_list.result[count.index]
  tags = {
    Name = "rshiwalkar_jenkins_public_${count.index + 1}"
  }
}

resource "aws_route_table" "rshiwalkar_jenkins_public_rt" {
  vpc_id = aws_vpc.rshiwalkar_jenkins_vpc.id
  tags = {
    Name = "rshiwalkar_jenkins_Public_RouteTable"
  }
}

resource "aws_route_table_association" "aws_public_association" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.rshiwalkar_jenkins_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.rshiwalkar_jenkins_public_rt.id
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.rshiwalkar_jenkins_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.rshiwalkar_jenkins_internet_gateway.id
}

resource "aws_internet_gateway" "rshiwalkar_jenkins_internet_gateway" {
  vpc_id = aws_vpc.rshiwalkar_jenkins_vpc.id
  tags = {
    Name = "rshiwalkar_igw"
  }
}


#----


resource "aws_subnet" "rshiwalkar_jenkins_private_subnet" {
  count                   = var.private_sn_count
  vpc_id                  = aws_vpc.rshiwalkar_jenkins_vpc.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = random_shuffle.az_list.result[count.index]
  tags = {
    Name = "rshiwalkar_jenkins_private_${count.index + 1}"
  }
}

resource "aws_default_route_table" "rshiwalkar_jenkins_private_rt" {
  default_route_table_id = aws_vpc.rshiwalkar_jenkins_vpc.default_route_table_id

  tags = {
    Name = "rshiwalkar-jenkins-private-rt"
  }
}

resource "aws_route_table_association" "aws_private_association" {
  count          = var.private_sn_count
  subnet_id      = aws_subnet.rshiwalkar_jenkins_private_subnet.*.id[count.index]
  route_table_id = aws_default_route_table.rshiwalkar_jenkins_private_rt.id
}

resource "aws_security_group" "sg_allow_ssh_jenkins" {
  name        = "allow_ssh_jenkins"
  description = "Allow SSH and Jenkins inbound traffic"
  vpc_id      = aws_vpc.rshiwalkar_jenkins_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}