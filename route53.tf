# 
# Creates a Route53 DNS zone for custom domain records
#
resource "aws_route53_zone" "dns_zone" {
  name                      = "${var.app_shortcode}.internal"
  comment                   = "Private DNS zone for mapping internal domain names for application ${var.app_name}"

  vpc {
    vpc_id                  = aws_vpc.vpc1.id
  }

  vpc {
    vpc_id                  = aws_vpc.vpc2.id
  }

  vpc {
      vpc_id                = aws_vpc.vpc3.id
  }
}