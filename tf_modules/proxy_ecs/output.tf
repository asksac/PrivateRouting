output "nlb_dns" {
  value   = aws_lb.nlb.dns_name 
}

output "endpoint_service_name" {
  value = aws_vpc_endpoint_service.vpces_nlb.service_name
}