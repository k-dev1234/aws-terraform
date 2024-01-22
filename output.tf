output "loadbalancer" {
  value = aws_lb.myalb.dns_name
}