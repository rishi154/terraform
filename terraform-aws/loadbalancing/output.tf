output "lb_target_group_arn" {
  value = aws_lb_target_group.rshiwalkar_tg.arn
}

output "lb_endpoint" {
  value = aws_lb.rshiwalkar_lb.dns_name
}