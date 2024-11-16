# CloudWatch Log Group for Front-End (Staging)
resource "aws_cloudwatch_log_group" "frontend_staging_log_group" {
  name              = "/eks/fargate/emirates-front-end/staging"
  retention_in_days = 7
  tags = {
    Environment = "staging"
    Service     = "front-end"
  }
}

# CloudWatch Log Group for Front-End (Production)
resource "aws_cloudwatch_log_group" "frontend_production_log_group" {
  name              = "/eks/fargate/emirates-front-end/production"
  retention_in_days = 7
  tags = {
    Environment = "production"
    Service     = "front-end"
  }
}

# CloudWatch Log Group for Back-End (Staging)
resource "aws_cloudwatch_log_group" "backend_staging_log_group" {
  name              = "/eks/fargate/emirates-back-end/staging"
  retention_in_days = 7
  tags = {
    Environment = "staging"
    Service     = "back-end"
  }
}

# CloudWatch Log Group for Back-End (Production)
resource "aws_cloudwatch_log_group" "backend_production_log_group" {
  name              = "/eks/fargate/emirates-back-end/production"
  retention_in_days = 7
  tags = {
    Environment = "production"
    Service     = "back-end"
  }
}
