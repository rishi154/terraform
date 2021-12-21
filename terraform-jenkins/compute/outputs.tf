output "jenkins_ip_address" {
  value =aws_instance.rshiwalkar_jenkins_node[0].public_dns
}