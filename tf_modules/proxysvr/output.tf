output "proxysvr_dns" {
  value = aws_instance.proxy.private_dns
}

output "nlb_arn" {
  value   = aws_lb.nlb.arn
}

output "nlb_dns" {
  value   = aws_lb.nlb.dns_name 
}
