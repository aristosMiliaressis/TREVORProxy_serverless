
resource "aws_appautoscaling_target" "proxy_cluster" {
  max_capacity       = var.proxy_count
  min_capacity       = 0
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.proxy_svc.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "proxy_scaling" {
  name               = "proxy-scaling"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.proxy_cluster.id
  scalable_dimension = aws_appautoscaling_target.proxy_cluster.scalable_dimension
  service_namespace  = aws_appautoscaling_target.proxy_cluster.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ExactCapacity"
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = 0
    }

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = var.proxy_count
    }
  }
}
