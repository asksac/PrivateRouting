resource "aws_vpc_endpoint_service" "vpces_nlb" {
  acceptance_required         = false
  network_load_balancer_arns  = [aws_lb.nlb.arn]
  tags                        = local.common_tags
}

resource "aws_vpc_endpoint" "vpce" {
  vpc_id       = aws_vpc.vpc1.id
  service_name = aws_vpc_endpoint_service.vpces_nlb.service_name
}