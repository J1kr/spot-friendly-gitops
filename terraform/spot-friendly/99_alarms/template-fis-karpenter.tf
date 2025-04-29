resource "aws_fis_experiment_template" "karpenter_spot_interrupt" {
  description = "Simulate Spot Interruption for Karpenter-managed instances"
  role_arn    = aws_iam_role.fis_karpenter.arn

  stop_condition {
    source = "none"
  }

  target {
    name           = "karpenter_spot_instances"
    resource_type  = "aws:ec2:spot-instance"
    selection_mode = "COUNT(1)"

    resource_tag {
      key   = "karpenter.sh/provisioner-name"
      value = "spot"
    }
  }

  action {
    name      = "interrupt_spot_instance"
    action_id = "aws:ec2:send-spot-instance-interruptions"

    parameter {
      key   = "durationBeforeInterruption"
      value = "PT2M"
    }

    target {
      key   = "SpotInstances"
      value = "karpenter_spot_instances"
    }
  }

  tags = {
    Name        = "karpenter-spot-interrupt-test"
    Environment = "dev"
  }
}