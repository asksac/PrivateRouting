output "private_dns" {
  value                   = aws_instance.client_ec2.private_dns
}

output "public_dns" {
  value                   = aws_instance.client_ec2.public_dns
}

output "alias_dns" {
  value                   = aws_route53_record.alias_dns.fqdn
}