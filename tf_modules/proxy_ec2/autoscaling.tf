locals {
  proxy_userdata          = templatefile("${path.module}/proxy_userdata.tpl", {
    aws_region            = var.aws_region
    port_mappings         = var.proxy_config.port_mappings
    ecr_docker_dns        = "${var.ecr_registry_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
    ecr_image_uri         = var.ecr_image_uri
    log_group_name        = aws_cloudwatch_log_group.ec2_proxy_log_group.name
  })
}

resource "aws_launch_template" "proxysvr_launch_template" {
  name_prefix             = "${var.app_shortcode}-proxysvr-launch-tpl"
  description             = "Proxy Server Launch Template"

  image_id                = var.ec2_ami_id
  instance_type           = var.instance_type

  user_data               = base64encode(local.proxy_userdata)

  iam_instance_profile {
    name                  = aws_iam_instance_profile.proxy_instance_profile.name
  } 
  key_name                = var.ec2_ssh_keypair_name
  vpc_security_group_ids  = [ aws_security_group.proxy_sg.id ]

  monitoring {
    enabled               = true
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type         = "instance"
    tags                  = merge(var.common_tags, map("Name", "${var.app_shortcode}-proxysvr"))
  }
}

resource "aws_autoscaling_group" "proxysvr_asg" {
  name_prefix             = "${var.app_shortcode}-proxysvr-asg"

  min_size                = var.min_cluster_size
  max_size                = var.max_cluster_size
  desired_capacity        = var.min_cluster_size

  health_check_type       = "EC2"
  vpc_zone_identifier     = var.subnet_ids

  launch_template {
    id                    = aws_launch_template.proxysvr_launch_template.id
    version               = "$Latest"
  }

  metrics_granularity     = "1Minute"
  enabled_metrics         = ["GroupDesiredCapacity", "GroupInServiceInstances"]

  target_group_arns       = [ 
    for tg in aws_lb_target_group.nlb_tgs: 
      tg.arn
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ desired_capacity ]
  }

  depends_on              = [ aws_launch_template.proxysvr_launch_template ]

  #tags                    = merge(var.common_tags, map("Name", "${var.app_shortcode}_proxysvr"))
}

resource "aws_autoscaling_policy" "proxysvr_asg_incr_policy" {
  name                    = "${var.app_shortcode}-proxysvr-asg-incr-policy"
  policy_type             = "SimpleScaling" # default is SimpleScaling
  scaling_adjustment      = 1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 180 # 3 minutes
  autoscaling_group_name  = aws_autoscaling_group.proxysvr_asg.name
}

resource "aws_autoscaling_policy" "proxysvr_asg_decr_policy" {
  name                    = "${var.app_shortcode}-proxysvr-asg-decr-policy"
  policy_type             = "SimpleScaling" # default is SimpleScaling
  scaling_adjustment      = -1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300 # 5 minutes
  autoscaling_group_name  = aws_autoscaling_group.proxysvr_asg.name
}
