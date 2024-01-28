
resource "aws_cloudwatch_metric_alarm" "active_proxy_intents" {
  alarm_name          = "active-proxy-intents"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1
  evaluation_periods  = 1
  treat_missing_data  = "ignore"

  metric_query {
    id = "visibleMessages"

    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = 60
      stat        = "Maximum"

      dimensions = {
        QueueName = aws_sqs_queue.proxy_intents.name
      }
    }
  }

  metric_query {
    id = "inFlightMessages"

    metric {
      metric_name = "ApproximateNumberOfMessagesNotVisible"
      namespace   = "AWS/SQS"
      period      = 60
      stat        = "Maximum"

      dimensions = {
        QueueName = aws_sqs_queue.proxy_intents.name
      }
    }
  }

  metric_query {
    id          = "allMessages"
    expression  = "visibleMessages + inFlightMessages"
    return_data = "true"
  }

  alarm_description = "This metric monitors active proxy intent messages."
  alarm_actions     = [aws_appautoscaling_policy.proxy_scaling.arn]
  ok_actions        = [aws_appautoscaling_policy.proxy_scaling.arn]
}
