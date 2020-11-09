output "endpoint_dns" {
  description             = "List of Private DNS entries associated with this VPC endpoint"
  value                   = aws_vpc_endpoint.vpce.dns_entry 
}

output "security_group_id" {
  description             = "Security Group ID associated with this VPC endpoint"
  value                   = aws_security_group.endpoint_sg.id
}

output "alias_dns" {
  description             = "FQDN of alias DNS record associated with this VPC endpoint"
  value                   = aws_route53_record.vpce_alias_dns.fqdn
}