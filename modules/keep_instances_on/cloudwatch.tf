
resource "aws_cloudwatch_event_rule" "keep-instances-running" {
  name          = "keep-instances-running"
  description   = "keep-instances-running"
  event_pattern = <<PATTERN
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "EC2 Instance State-change Notification"
  ],
  "detail": {
    "state": [
      "stopped"
    ]
  }
}
PATTERN
}


resource "aws_cloudwatch_event_target" "keep-instances-running" {
  rule = aws_cloudwatch_event_rule.keep-instances-running.name
  arn  = aws_lambda_function.keep-instances-running.arn
}

resource "aws_lambda_permission" "keep-instances-running" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.keep-instances-running.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.keep-instances-running.arn
}

