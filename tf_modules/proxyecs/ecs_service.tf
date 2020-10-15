resource "aws_ecs_cluster" "main" {
  name                      = "${var.app_shortcode}-ecs-cluster"
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
    "image": "${var.image_uri}",
    "name": "${var.proxy_config.service_name}",
    "networkMode": "awsvpc",
    "portMappings": ${local.port_mappings_task_def_json}, 
    "ulimits": [
      {
        "softLimit": 16384,
        "hardLimit": 16384,
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
  name                      = "${var.app_shortcode}-ecs-service"
  cluster                   = aws_ecs_cluster.main.id
  task_definition           = aws_ecs_task_definition.proxy_task.arn
  desired_count             = "2"
  launch_type               = "FARGATE"

  network_configuration {
    security_groups         = [ aws_security_group.proxy_sg.id ]
    subnets                 = var.subnet_ids
  }

  dynamic "load_balancer" {
    for_each                = var.proxy_config.port_mappings

    content {
      target_group_arn      = aws_lb_target_group.nlb_tg_ecs[load_balancer.key].id
      container_name        = var.proxy_config.service_name
      container_port        = load_balancer.value.proxy_port
    }
  }

  depends_on                = [ aws_lb_listener.nlb_listener_ecs ]
}