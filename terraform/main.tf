# If Lambda is only triggered by EventBridge rules, don’t need to add EventBridge permissions inside the Lambda IAM role
# explicitly grant EventBridge permission to invoke Lambda is done with the aws_lambda_permission resource
# EventBridge rule (example)
resource "aws_cloudwatch_event_rule" "my_rule" {
  name        = "my-eventbridge-rule"
  description = "Trigger Lambda on schedule"
  schedule_expression = "rate(24 hours)" # every 24 hours
}

# EventBridge target (the Lambda function)
resource "aws_cloudwatch_event_target" "my_target" {
  rule      = aws_cloudwatch_event_rule.my_rule.name
  target_id = "my-lambda"
  arn       = aws_lambda_function.my_lambda.arn
}

# Permission so EventBridge can invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.my_rule.arn
}
