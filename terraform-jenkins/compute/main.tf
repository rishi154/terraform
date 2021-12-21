data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "random_id" "rshiwalkar_node_id" {
  byte_length = 2
  count       = var.instance_count
  keepers = {
    key_name = var.key_name
  }
}

resource "aws_key_pair" "pc_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "rshiwalkar_jenkins_node" {
  count         = var.instance_count # 1
  instance_type = var.instance_type  # t3.micro
  ami           = data.aws_ami.server_ami.id
  tags = {
    Name = "rshiwalkar_jenkins_node-${random_id.rshiwalkar_node_id[count.index].dec}"
  }
  key_name               = aws_key_pair.pc_auth.id
  vpc_security_group_ids = [var.public_sg]
  subnet_id              = var.public_subnets[count.index]
  user_data = file("install_jenkins.sh")
  associate_public_ip_address = true
}