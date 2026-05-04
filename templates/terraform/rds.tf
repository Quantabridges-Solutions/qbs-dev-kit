# ── RDS PostgreSQL 16 (conditional — set create_rds = true in tfvars) ─────────
# For cost savings on small projects, consider a managed DB service or
# include DB in the Lambda environment via connection string to an existing DB.

variable "create_rds" {
  description = "Whether to create an RDS PostgreSQL instance"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID for RDS + Lambda (required when create_rds = true)"
  type        = string
  default     = ""
}

variable "db_subnet_ids" {
  description = "Subnet IDs for the RDS DB subnet group (minimum 2 in different AZs)"
  type        = list(string)
  default     = []
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_name" {
  type    = string
  default = ""
}

variable "db_username" {
  type      = string
  sensitive = true
  default   = ""
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = ""
}

locals {
  lambda_in_vpc            = var.create_rds
  lambda_security_group_name = "${var.project_name}-lambda-sg-${var.environment}"
  db_security_group_name   = "${var.project_name}-db-sg-${var.environment}"
  prefix                   = "${var.project_name}-${var.environment}"
}

resource "aws_security_group" "lambda" {
  count = local.lambda_in_vpc ? 1 : 0

  name        = local.lambda_security_group_name
  description = "Security group for ${var.project_name} Lambda API"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "postgres" {
  count = var.create_rds ? 1 : 0

  name        = local.db_security_group_name
  description = "Security group for ${var.project_name} PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda[0].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "postgres" {
  count = var.create_rds ? 1 : 0

  name       = "${local.prefix}-db-subnets"
  subnet_ids = var.db_subnet_ids
}

resource "aws_db_instance" "postgres" {
  count = var.create_rds ? 1 : 0

  identifier             = "${local.prefix}-postgres"
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  storage_encrypted      = true
  skip_final_snapshot    = var.environment != "production"
  deletion_protection    = var.environment == "production"
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.postgres[0].name
  vpc_security_group_ids = [aws_security_group.postgres[0].id]
}

output "db_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = var.create_rds ? aws_db_instance.postgres[0].endpoint : "not created"
}
