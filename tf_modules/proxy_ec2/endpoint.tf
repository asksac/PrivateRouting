resource "aws_vpc_endpoint_service" "vpces_nlb" {
  acceptance_required         = false
  network_load_balancer_arns  = [ aws_lb.nlb.arn ]
  tags                        = merge(var.common_tags, map("Name", "${var.app_shortcode}-proxysvr-nlb-endpointsvc"))

  lifecycle {
    create_before_destroy     = true
  }
}