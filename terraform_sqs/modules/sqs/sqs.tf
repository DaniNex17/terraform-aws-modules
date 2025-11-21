resource "aws_sqs_queue" "this" {
  name                              = var.use_name_prefix ? null : (var.fifo_queue ? "${var.queue_name}.fifo" : var.queue_name)
  name_prefix                       = var.use_name_prefix ? "${var.queue_name}-" : null
  delay_seconds                     = var.delay_seconds
  max_message_size                  = var.max_message_size
  message_retention_seconds         = var.message_retention_seconds
  receive_wait_time_seconds         = var.receive_wait_time_seconds
  visibility_timeout_seconds        = var.visibility_timeout_seconds
  fifo_queue                        = var.fifo_queue
  fifo_throughput_limit             = var.fifo_queue ? var.fifo_throughput_limit : null
  content_based_deduplication       = var.fifo_queue ? var.content_based_deduplication : null
  deduplication_scope               = var.fifo_queue ? var.deduplication_scope : null
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
  redrive_policy                    = var.redrive_policy != null ? jsonencode(var.redrive_policy) : null

  tags = var.tags
}

resource "aws_sqs_queue_redrive_allow_policy" "this" {
  count     = var.arn_sqs_source_to_this_dlq != null && length(coalesce(var.arn_sqs_source_to_this_dlq, [])) > 0 ? 1 : 0
  queue_url = aws_sqs_queue.this.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = var.arn_sqs_source_to_this_dlq
  })
}
