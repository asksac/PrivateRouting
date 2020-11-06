resource "aws_appautoscaling_target" "ecs_scaling_target" {
  count                           = local.port_mappings_group_count

  service_namespace               = "ecs"
  resource_id                     = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main[count.index].name}"
  scalable_dimension              = "ecs:service:DesiredCount"
  
  min_capacity                    = var.ecs_autoscale_min_instances
  max_capacity                    = var.ecs_autoscale_max_instances
}

resource "aws_appautoscaling_policy" "scale_up" {
  count                           = local.port_mappings_group_count

  name                            = "${var.app_shortcode}-${var.proxy_config.service_name}-scale-up-${count.index}"
  service_namespace               = aws_appautoscaling_target.ecs_scaling_target[count.index].service_namespace
  resource_id                     = aws_appautoscaling_target.ecs_scaling_target[count.index].resource_id
  scalable_dimension              = aws_appautoscaling_target.ecs_scaling_target[count.index].scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type               = "ChangeInCapacity"
    cooldown                      = 60
    metric_aggregation_type       = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "scale_down" {
  count                           = local.port_mappings_group_count

  name                            = "${var.app_shortcode}-${var.proxy_config.service_name}-scale-down-${count.index}"
  service_namespace               = aws_appautoscaling_target.ecs_scaling_target[count.index].service_namespace
  resource_id                     = aws_appautoscaling_target.ecs_scaling_target[count.index].resource_id
  scalable_dimension              = aws_appautoscaling_target.ecs_scaling_target[count.index].scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type               = "ChangeInCapacity"
    cooldown                      = 300
    metric_aggregation_type       = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}