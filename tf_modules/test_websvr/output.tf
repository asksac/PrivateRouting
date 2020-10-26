output "private_dns" {
  value                   = aws_instance.websvr.private_dns
}

output "private_ip" {
  value                   = aws_instance.websvr.private_ip
}

output "public_dns" {
  value                   = aws_instance.websvr.public_dns
}

output "alias_dns" {
  value                   = aws_route53_record.alias_dns.fqdn
}

output "instance_id" {
  value                   = aws_instance.websvr.id
}
