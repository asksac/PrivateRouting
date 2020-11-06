# create a custom route53 record pointing to nlb
resource "aws_route53_record" "nlb_dns" {
  zone_id                 = var.dns_zone_id
  name                    = var.dns_custom_hostname 
  type                    = "A"

  alias {
    name                  = aws_lb.nlb.dns_name
    zone_id               = aws_lb.nlb.zone_id
    evaluate_target_health= true
  }
}
