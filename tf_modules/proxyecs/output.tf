output "nlb_arn" {
  value   = aws_lb.nlb.arn 
}

output "nlb_dns" {
  value   = aws_lb.nlb.dns_name 
}

output "ecr_url" {
  value = aws_ecr_repository.registry.repository_url
}