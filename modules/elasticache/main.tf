variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for ElastiCache"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "Security group ID of the EKS cluster to allow access"
  type        = string
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.environment}-redis-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "redis" {
  name        = "${var.environment}-redis-sg"
  description = "Allow inbound access from EKS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.cluster_security_group_id]
  }

  tags = {
    Name        = "${var.environment}-redis-sg"
    Environment = var.environment
  }
}

resource "aws_elasticache_cluster" "main" {
  cluster_id           = "${var.environment}-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.2"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.redis.id]

  tags = {
    Environment = var.environment
  }
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.main.cache_nodes[0].address
}
