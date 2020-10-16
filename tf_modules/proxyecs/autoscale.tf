resource "aws_appautoscaling_target" "ecs_scaling_target" {
  service_namespace               = "ecs"
  resource_id                     = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension              = "ecs:service:DesiredCount"
  
  max_capacity                    = var.ecs_autoscale_max_instances
  min_capacity                    = var.ecs_autoscale_min_instances
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  alarm_name                      = "${var.app_shortcode}-high-cpu-alarm"
  comparison_operator             = "GreaterThanOrEqualToThreshold"
  evaluation_periods              = "1"
  metric_name                     = "CPUUtilization"
  namespace                       = "AWS/ECS"
  period                          = "60"
  statistic                       = "Average"
  threshold                       = var.ecs_high_cpu_mark

  dimensions = {
    ClusterName                   = aws_ecs_cluster.main.name
    ServiceName                   = aws_ecs_service.main.name
  }

  alarm_actions                   = [ aws_appautoscaling_policy.scale_up.arn ]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  alarm_name                      = "${var.app_shortcode}-low-cpu-alarm"
  comparison_operator             = "LessThanThreshold"
  evaluation_periods              = "1"
  metric_name                     = "CPUUtilization"
  namespace                       = "AWS/ECS"
  period                          = "60"
  statistic                       = "Average"
  threshold                       = var.ecs_low_cpu_mark

  dimensions = {
    ClusterName                   = aws_ecs_cluster.main.name
    ServiceName                   = aws_ecs_service.main.name
  }

  alarm_actions                   = [ aws_appautoscaling_policy.scale_down.arn ]
}

resource "aws_appautoscaling_policy" "scale_up" {
  name                            = "${var.app_shortcode}-ecs-scale-up"
  service_namespace               = aws_appautoscaling_target.ecs_scaling_target.service_namespace
  resource_id                     = aws_appautoscaling_target.ecs_scaling_target.resource_id
  scalable_dimension              = aws_appautoscaling_target.ecs_scaling_target.scalable_dimension

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
  name                            = "${var.app_shortcode}-ecs-scale-down"
  service_namespace               = aws_appautoscaling_target.ecs_scaling_target.service_namespace
  resource_id                     = aws_appautoscaling_target.ecs_scaling_target.resource_id
  scalable_dimension              = aws_appautoscaling_target.ecs_scaling_target.scalable_dimension

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