output "public_sg" {
  value = aws_security_group.sg_allow_ssh_jenkins.id
}

output "public_subnets" {
  value = aws_subnet.rshiwalkar_jenkins_public_subnet.*.id
}