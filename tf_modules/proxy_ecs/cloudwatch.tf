resource "aws_cloudwatch_log_group" "ecs_proxy_log_group" {
  name                            = "${var.app_name}/${var.proxy_config.service_name}"
  tags                            = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  count                           = local.port_mappings_group_count

  alarm_name                      = "${var.app_shortcode}-${var.proxy_config.service_name}-high-cpu-alarm-${count.index}"
  comparison_operator             = "GreaterThanOrEqualToThreshold"
  evaluation_periods              = "1"
  metric_name                     = "CPUUtilization"
  namespace                       = "AWS/ECS"
  period                          = "60"
  statistic                       = "Average"
  threshold                       = var.autoscaling_high_cpu_mark

  dimensions = {
    ClusterName                   = aws_ecs_cluster.main.name
    ServiceName                   = aws_ecs_service.main[count.index].name
  }

  alarm_actions                   = [ aws_appautoscaling_policy.scale_up[count.index].arn ]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  count                           = local.port_mappings_group_count

  alarm_name                      = "${var.app_shortcode}-${var.proxy_config.service_name}-low-cpu-alarm-${count.index}"
  comparison_operator             = "LessThanThreshold"
  evaluation_periods              = "1"
  metric_name                     = "CPUUtilization"
  namespace                       = "AWS/ECS"
  period                          = "60"
  statistic                       = "Average"
  threshold                       = var.autoscaling_low_cpu_mark

  dimensions = {
    ClusterName                   = aws_ecs_cluster.main.name
    ServiceName                   = aws_ecs_service.main[count.index].name
  }

  alarm_actions                   = [ aws_appautoscaling_policy.scale_down[count.index].arn ]
}
