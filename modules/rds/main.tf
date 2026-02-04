variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for RDS"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "Security group ID of the EKS cluster to allow access"
  type        = string
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Allow inbound access from EKS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.cluster_security_group_id]
  }

  tags = {
    Name        = "${var.environment}-rds-sg"
    Environment = var.environment
  }
}

resource "aws_db_instance" "main" {
  identifier           = "${var.environment}-postgres"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "13"
  instance_class       = "db.t3.micro"
  username             = "postgres"
  password             = "ChangeMe123!" # In production, use Secrets Manager
  parameter_group_name = "default.postgres13"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  tags = {
    Name        = "${var.environment}-postgres"
    Environment = var.environment
  }
}

output "db_endpoint" {
  value = aws_db_instance.main.endpoint
}
