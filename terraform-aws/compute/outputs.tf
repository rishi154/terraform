output "instance" {
  value = aws_instance.rshiwalkar_node[*]
}

output "instance_port" {
  value = aws_lb_target_group_attachment.rshiwalkar_tg_attach[0].port
}