resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  alarm_name              = "${var.app_shortcode}-proxysvr-high-cpu-alarm"
  comparison_operator     = "GreaterThanOrEqualToThreshold"
  evaluation_periods      = "1"
  metric_name             = "CPUUtilization"
  namespace               = "AWS/EC2"
  period                  = "60"
  statistic               = "Average"
  threshold               = var.autoscaling_high_cpu_mark

  dimensions = {
    AutoScalingGroupName  = aws_autoscaling_group.proxysvr_asg.name
  }

  alarm_actions           = [ aws_autoscaling_policy.proxysvr_asg_incr_policy.arn ]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  alarm_name              = "${var.app_shortcode}-proxysvr-low-cpu-alarm"
  comparison_operator     = "LessThanThreshold"
  evaluation_periods      = "1"
  metric_name             = "CPUUtilization"
  namespace               = "AWS/ECS"
  period                  = "60"
  statistic               = "Average"
  threshold               = var.autoscaling_low_cpu_mark

  dimensions = {
    AutoScalingGroupName  = aws_autoscaling_group.proxysvr_asg.name
  }

  alarm_actions           = [ aws_autoscaling_policy.proxysvr_asg_decr_policy.arn ]
}

resource "aws_cloudwatch_log_group" "ec2_proxy_log_group" {
  name                  = "${var.app_name}/${var.proxy_config.service_name}"
  tags                  = var.common_tags
}