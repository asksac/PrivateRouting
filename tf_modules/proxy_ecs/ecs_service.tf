resource "aws_ecs_cluster" "main" {
  name                      = "${var.app_shortcode}-${var.proxy_config.service_name}-cluster"
  tags                      = var.common_tags
}

resource "aws_ecs_task_definition" "proxy_task" {
  family                    = var.proxy_config.service_name
  network_mode              = "awsvpc"
  requires_compatibilities  = ["FARGATE"]
  cpu                       = "1024"
  memory                    = "2048"
  execution_role_arn        = aws_iam_role.proxy_exec_role.arn

  container_definitions     = <<DEFINITION
[
  {
    "image": "${var.ecr_image_uri}",
    "name": "${var.proxy_config.service_name}",
    "networkMode": "awsvpc",
    "portMappings": ${local.port_mappings_task_def_json}, 
    "ulimits": [
      {
        "softLimit": 65535,
        "hardLimit": 65535,
        "name": "nofile"
      }
    ], 
    "secrets": [{
      "name": "HAPROXY_CONFIG",
      "valueFrom": "${aws_ssm_parameter.haproxy_config.arn}"
    }], 
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.ecs_proxy_log_group.name}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "ecs-task"
      }
    }
  }
]
DEFINITION

  depends_on                = [ aws_ssm_parameter.haproxy_config ] 
  tags                      = var.common_tags
}

resource "aws_ecs_service" "main" {
  count                     = local.port_mappings_group_count

  name                      = "${var.app_shortcode}-${var.proxy_config.service_name}-service-${count.index}"
  cluster                   = aws_ecs_cluster.main.id
  task_definition           = aws_ecs_task_definition.proxy_task.arn
  desired_count             = var.min_cluster_size
  launch_type               = "FARGATE"

  lifecycle {
    ignore_changes          = [ desired_count ]
  }

  deployment_maximum_percent          = 200
  deployment_minimum_healthy_percent  = 50
  health_check_grace_period_seconds   = 15

  network_configuration {
    security_groups         = [ aws_security_group.proxy_sg.id ]
    subnets                 = var.subnet_ids
  }

  dynamic "load_balancer" {
    for_each                = local.port_mappings_group_map[count.index] 

    content {
      target_group_arn      = aws_lb_target_group.nlb_tgs[load_balancer.key].id
      container_name        = var.proxy_config.service_name
      container_port        = load_balancer.value.proxy_port
    }
  }

  depends_on                = [ aws_lb_listener.nlb_listeners, aws_security_group.proxy_sg ]
}