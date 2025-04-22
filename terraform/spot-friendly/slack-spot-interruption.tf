# SNS Topic for interruption events
resource "aws_sns_topic" "spot_interruptions" {
  name = "spot-interruptions-topic"
}

# IAM Role for Lambda execution
resource "aws_iam_role" "lambda_exec" {
  name = "spot-slack-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM policy attachment for basic Lambda logging
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function to send message to Slack
resource "aws_lambda_function" "spot_slack_notifier" {
  filename         = "lambda/slack-notifier.zip"
  function_name    = "spot-slack-notifier"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "slack-notifier.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = filebase64sha256("lambda/slack-notifier.zip")

  environment {
    variables = {
      SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/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"
    }
  }
}

# Subscribe Lambda to SNS
resource "aws_sns_topic_subscription" "lambda_sub" {
  topic_arn = aws_sns_topic.spot_interruptions.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.spot_slack_notifier.arn
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.spot_slack_notifier.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.spot_interruptions.arn
}

# CloudWatch Event Rule to detect Spot interruption
resource "aws_cloudwatch_event_rule" "spot_interruption" {
  name        = "spot-interruption-rule"
  description = "Trigger SNS on EC2 Spot Instance interruption"
  event_pattern = jsonencode({
    "source": ["aws.ec2"],
    "detail-type": ["EC2 Spot Instance Interruption Warning"]
  })
}

# EventBridge to SNS target
resource "aws_cloudwatch_event_target" "send_to_sns" {
  rule      = aws_cloudwatch_event_rule.spot_interruption.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.spot_interruptions.arn
}

# Permission for EventBridge to publish to SNS
resource "aws_sns_topic_policy" "sns_policy" {
  arn    = aws_sns_topic.spot_interruptions.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = { Service = "events.amazonaws.com" },
        Action = "sns:Publish",
        Resource = aws_sns_topic.spot_interruptions.arn
      }
    ]
  })
} 
