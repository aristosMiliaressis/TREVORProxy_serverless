resource "aws_sqs_queue" "proxy_intents" {
  name                       = "proxy-intents.fifo"
  fifo_queue                 = true
  sqs_managed_sse_enabled    = true
  visibility_timeout_seconds = 30
  message_retention_seconds  = var.message_retention_seconds

  tags = {
    Description = "TREVORProxy intent message queue."
  }
}
