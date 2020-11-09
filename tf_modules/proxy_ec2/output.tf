output "nlb_arn" {
  description             = "ARN of Network Load Balancer fronting the HAProxy cluster"
  value                   = aws_lb.nlb.arn 
}

output "nlb_dns" {
  description             = "DNS name of Network Load Balancer fronting the HAProxy cluster"
  value                   = aws_lb.nlb.dns_name 
}

output "nlb_alias_fqdn" {
  description             = "FQDN of alias DNS record associated with the Network Load Balancer"
  value                   = aws_route53_record.nlb_dns.fqdn
}

output "security_group_id" {
  description             = "Security Group ID associated with the HAProxy cluster"
  value                   = aws_security_group.proxy_sg.id 
}

output "endpoint_service_name" {
  description             = "VPC Endpoint Service Name of the Network Load Balancer"
  value                   = aws_vpc_endpoint_service.vpces_nlb.service_name
}