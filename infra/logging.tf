resource "aws_iam_role" "lambda_cloudwatch_to_s3_role" {
  name = "lambda_cloudwatch_to_s3_role"

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

resource "aws_iam_policy" "lambda_cloudwatch_to_s3_policy" {
  name = "lambda_cloudwatch_to_s3_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:PutSubscriptionFilter"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "s3:PutObject"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::emirates-private-store/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_cloudwatch_to_s3_role.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_to_s3_policy.arn
}

#---------------- Lambda

resource "aws_lambda_function" "cloudwatch_to_s3" {
  function_name    = "cloudwatch_logs_to_s3"
  role             = aws_iam_role.lambda_cloudwatch_to_s3_role.arn
  handler          = "lambda_function.lambda_handler" 
  runtime          = "python3.8"
  filename         = "lambda_function.zip" # Specify the path to your local zip file
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      S3_BUCKET = "emirates-private-store"
      S3_PREFIX = "staging/"
    }
  }
}

data "aws_caller_identity" "current" {}

# Upload Lambda code
resource "aws_s3_object" "lambda_code" {
  bucket = "emirates-private-store"
  key    = "lambda_function.zip"
  source = "lambda_function.zip"
}

resource "aws_cloudwatch_log_subscription_filter" "subscription_filter" {
  name            = "cloudwatch_to_s3_subscription"
  log_group_name  = "/eks/fargate/emirates-front-end/staging"
  filter_pattern  = ""
  destination_arn = aws_lambda_function.cloudwatch_to_s3.arn
}



resource "aws_cloudwatch_event_rule" "daily_log_event" {
  name                = "daily-log-push"
  schedule_expression = "cron(0 0 * * ? *)" # Every day at midnight UTC
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_log_event.name
  target_id = "lambda_target"
  arn       = aws_lambda_function.cloudwatch_to_s3.arn
}


resource "aws_lambda_permission" "allow_cloudwatch_events" {
  statement_id  = "AllowExecutionFromCloudWatchEvents"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudwatch_to_s3.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_log_event.arn
}
