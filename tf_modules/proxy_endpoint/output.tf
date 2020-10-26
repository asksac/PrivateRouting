output "endpoint_dns" {
  value                   = aws_vpc_endpoint.vpce.dns_entry 
}

output "security_group_id" {
  value                   = aws_security_group.endpoint_sg.id
}

output "alias_dns" {
  value                   = aws_route53_record.vpce_alias_dns.fqdn
}