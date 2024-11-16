# Define security group for Redis
resource "aws_security_group" "redis_sg" {
  vpc_id = aws_vpc.eks-demo-vpc-01.id # Correcting the resource name here

  # Allow inbound Redis traffic (port 6379)
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Allow traffic from within the VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redis-security-group"
  }
}

# Define security group for EKS Fargate
resource "aws_security_group" "eks_sg" {
  vpc_id = aws_vpc.eks-demo-vpc-01.id # Correcting the resource name here

  # Allow inbound traffic from Redis and other necessary ports
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-security-group"
  }
}

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = [aws_subnet.eks-demo-private-01.id, aws_subnet.eks-demo-private-02.id] # Correcting the resource names here

  tags = {
    Name = "Redis Subnet Group"
  }
}

# Redis Replication Group for Staging
resource "aws_elasticache_replication_group" "redis_staging" {
  replication_group_id       = "redis-replication-group-staging"
  description                = "Redis Replication Group for Staging" # Correct argument
  node_type                  = "cache.t3.micro"
  num_node_groups            = 1
  replicas_per_node_group    = 0 # If you do not want any replicas
  subnet_group_name          = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids         = [aws_security_group.redis_sg.id]
  engine                     = "redis"
  engine_version             = "6.x"
  port                       = 6379
  automatic_failover_enabled = false
  at_rest_encryption_enabled = true

  tags = {
    Name = "Redis Cluster terraform managed staging"
  }
}


# Redis Replication Group for Production
resource "aws_elasticache_replication_group" "redis_production" {
  replication_group_id       = "redis-replication-group-production"
  description                = "Redis Replication Group for Production" # Correct argument
  node_type                  = "cache.t3.micro"
  num_node_groups            = 1
  replicas_per_node_group    = 0 # If you do not want any replicas
  subnet_group_name          = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids         = [aws_security_group.redis_sg.id]
  engine                     = "redis"
  engine_version             = "6.x"
  port                       = 6379
  automatic_failover_enabled = false
  at_rest_encryption_enabled = true

  tags = {
    Name = "Redis Cluster terraform managed production"
  }
}

# Allow Redis access from EKS Fargate (both staging and production)
resource "aws_security_group_rule" "allow_eks_access_to_redis" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis_sg.id
  source_security_group_id = aws_security_group.eks_sg.id
}

#------------- output --------------

# Output for Redis Staging endpoint
output "redis_staging_endpoint" {
  description = "The Redis endpoint for the staging environment"
  value       = aws_elasticache_replication_group.redis_staging.primary_endpoint_address
}

# Output for Redis Production endpoint
output "redis_production_endpoint" {
  description = "The Redis endpoint for the production environment"
  value       = aws_elasticache_replication_group.redis_production.primary_endpoint_address
}

