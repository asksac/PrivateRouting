/**
 * # Module: proxy_ecs
 *
 * This module can be used to deploy HAProxy running on an ECS Fargate cluster, with capacity automatically managed based on specified min and max cluster sizes, and auto-scaling low and high cpu marks. Each module can support up to 50 port mapping rules specified through `proxy_config` variable. Module will create multiple ECS Services, one for every 5 port mapping rules. 
 * 
 * ### Usage: 
 * 
 * ```hcl
 * module "proxy_ecs" {
 *   source                    = "./tf_modules/proxy_ecs"
 *
 *   aws_region                = "us-east-1"
 *   app_name                  = "PrivateRouting"
 *   app_shortcode             = "prt"
 *
 *   vpc_id                    = aws_vpc.my_routable_vpc.id
 *   subnet_ids                = [ aws_subnet.my_routable_vpc_subnet1.id, aws_subnet.my_routable_vpc_subnet2.id ]
 *
 *   dns_zone_id               = aws_route53_zone.my_dns_zone.zone_id  
 *   dns_custom_hostname       = "myproxy"
 *
 *   source_cidr_blocks        = [ aws_vpc.my_routable_vpc.cidr_block ]
 *   ecr_image_uri             = "${aws_ecr_repository.my_registry.repository_url}:1.0"
 *
 *   min_cluster_size          = 1
 *   max_cluster_size          = 4
 *   autoscaling_low_cpu_mark  = 25
 *   autoscaling_high_cpu_mark = 75
 *
 *   proxy_config              = {
 *     service_name            = "myproxy"
 *     port_mappings           = [
 *       {
 *         name                = "api_svc"
 *         description         = "HTTPS connection to backend API service"
 *         backend_host        = "api.corp.mydomain.net"
 *         backend_port        = 443
 *         nlb_port            = 8443
 *         proxy_port          = 8443
 *       }, 
 *       {
 *         name                = "sftp_svr"
 *         description         = "SFTP connection to backend file server"
 *         backend_host        = "filesvr.corp.mydomain.net"
 *         backend_port        = 22
 *         nlb_port            = 7022
 *         proxy_port          = 7022
 *       }
 *     ]
 *   }
 *
 *   common_tags               = local.common_tags
 * }
 * ```
 */

terraform {
  required_version    = ">= 0.12"
  required_providers {
    aws               = ">= 3.11.0"
  }
}