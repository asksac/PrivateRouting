output "nlb_arn" {
  value                   = aws_lb.nlb.arn 
}

output "nlb_dns" {
  value                   = aws_lb.nlb.dns_name 
}

output "security_group_id" {
  value                   = aws_security_group.proxy_sg.id 
}

output "endpoint_service_name" {
  value                   = aws_vpc_endpoint_service.vpces_nlb.service_name
}