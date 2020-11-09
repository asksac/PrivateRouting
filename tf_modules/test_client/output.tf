output "private_dns" {
  description             = "Private DNS name associated with this client ec2 instance"
  value                   = aws_instance.client_ec2.private_dns
}

output "public_dns" {
  description             = "Public DNS name associated with this client ec2 instance, if available"
  value                   = aws_instance.client_ec2.public_dns
}

output "alias_dns" {
  description             = "FQDN of alias DNS name associated with this client ec2 instance"
  value                   = aws_route53_record.alias_dns.fqdn
}