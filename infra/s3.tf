resource "aws_s3_bucket" "staging-logs" {

  bucket = "skywardsrail-logs-staging"

  tags = {
    Environment = "staging"
  }
}

resource "aws_s3_bucket" "prod-logs" {
  bucket = "skywardsrail-logs-prod"

  tags = {
    Environment = "production"
  }
}

# S3 bucket creation without acl
resource "aws_s3_bucket" "emirates_private_store" {
  bucket = "emirates-private-store"

  tags = {
    Name        = "Emirates Private Store"
    Environment = "Production"
  }
}

# S3 Access Point for Emirates Private Store
resource "aws_s3_access_point" "emirates_access_point" {
  bucket = aws_s3_bucket.emirates_private_store.id
  name   = "emirates-private-store-ap"

  vpc_configuration {
    vpc_id = "vpc-08f8a860173a45300" # Your VPC ID
  }

  public_access_block_configuration {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

resource "aws_s3_bucket_policy" "emirates_private_store_policy" {
  bucket = aws_s3_bucket.emirates_private_store.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = [
            "arn:aws:iam::640965039626:user/ShafqatMasood",
            "arn:aws:iam::640965039626:user/SandeepShetty",
            "arn:aws:iam::640965039626:user/terraform-uae"
          ]
        },
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::emirates-private-store",
          "arn:aws:s3:::emirates-private-store/*"
        ]
      }
    ]
  })
}



# Output the access point ARN
output "s3_access_point_arn" {
  value = aws_s3_access_point.emirates_access_point.arn
}
