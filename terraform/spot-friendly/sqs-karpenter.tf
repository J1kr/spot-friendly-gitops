resource "aws_sqs_queue" "karpenter_interruption_queue" {
  name = "${var.cluster_name}-queue"

  # FIFO 아님, 일반 큐
  fifo_queue = false

  # Optional: visibility timeout 등 조정 가능
  visibility_timeout_seconds = 30

  tags = {
    Name = "karpenter-interruption-queue"
  }
}