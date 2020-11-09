output "private_dns" {
  description             = "Private DNS name associated with this webserver instance"
  value                   = aws_instance.websvr.private_dns
}

output "private_ip" {
  description             = "Private IP address associated with this webserver instance"
  value                   = aws_instance.websvr.private_ip
}

output "public_dns" {
  description             = "Private DNS name associated with this webserver instance"
  value                   = aws_instance.websvr.public_dns
}

output "alias_dns" {
  description             = "FQDN of alias DNS name associated with this webserver instance"
  value                   = aws_route53_record.alias_dns.fqdn
}

output "instance_id" {
  description             = "EC2 instance id of this webserver"
  value                   = aws_instance.websvr.id
}
