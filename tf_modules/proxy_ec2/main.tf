/**
 * # Module: proxy_ec2
 *
 * This module can be used to deploy an HAProxy cluster running on EC2 instances, and managed by an EC2 Auto Scaling group. Each instance of the module can support upto 50 port mappings in the proxy configuration. 
 * 
 * ### Usage: 
 * 
 * ```hcl
 * module "proxy_ec2" {
 *   source                    = "./tf_modules/proxy_ec2"
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
 *   ec2_ami_id                = data.aws_ami.ec2_ami.id
 *   instance_type             = "t3.medium"
 *   ec2_ssh_enabled           = true
 *   ec2_ssh_keypair_name      = "my_ssh_keypair"
 *   ssh_source_cidr_blocks    = [ aws_vpc.my_bastion_vpc.cidr_block ]
 *   source_cidr_blocks        = [ aws_vpc.my_routable_vpc.cidr_block ]
 *
 *   ecr_registry_id           = aws_ecr_repository.my_registry.registry_id
 *   ecr_image_uri             = "${aws_ecr_repository.my_registry.repository_url}:1.0"
 *
 *   min_cluster_size          = 1
 *   max_cluster_size          = 4
 *   autoscaling_low_cpu_mark  = 25
 *   autoscaling_high_cpu_mark = 75
 *
 *   proxy_config              = {
 *     service_name            = "myec2proxy"
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