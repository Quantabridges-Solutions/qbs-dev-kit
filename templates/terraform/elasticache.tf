# ── ElastiCache Redis (optional) ──────────────────────────────────────────────
# Requires the same VPC + private subnets as RDS (var.vpc_id, var.db_subnet_ids).
# When enabled, Lambda is placed in the VPC (see rds.tf local.lambda_in_vpc).

variable "create_elasticache" {
  description = "Whether to create an ElastiCache Redis cluster"
  type        = bool
  default     = false
}

variable "redis_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.1"
}

variable "redis_num_cache_nodes" {
  type    = number
  default = 1
}

locals {
  redis_sg_name     = "${var.project_name}-redis-sg-${var.environment}"
  redis_subnet_name = "${local.prefix}-redis-subnets"
}

resource "aws_security_group" "redis" {
  count = var.create_elasticache ? 1 : 0

  name        = local.redis_sg_name
  description = "Security group for ${var.project_name} Redis"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
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

resource "aws_elasticache_subnet_group" "redis" {
  count = var.create_elasticache ? 1 : 0

  name       = local.redis_subnet_name
  subnet_ids = var.db_subnet_ids
}

resource "aws_elasticache_cluster" "redis" {
  count = var.create_elasticache ? 1 : 0

  cluster_id                 = "${local.prefix}-redis"
  engine                     = "redis"
  engine_version             = var.redis_engine_version
  node_type                  = var.redis_node_type
  num_cache_nodes            = var.redis_num_cache_nodes
  port                       = 6379
  parameter_group_name       = "default.redis7"
  subnet_group_name          = aws_elasticache_subnet_group.redis[0].name
  security_group_ids         = [aws_security_group.redis[0].id]
  at_rest_encryption_enabled = true
}

output "redis_endpoint" {
  description = "ElastiCache Redis primary endpoint (host:port). Use as ConnectionStrings__Redis."
  value       = var.create_elasticache ? "${aws_elasticache_cluster.redis[0].cache_nodes[0].address}:${aws_elasticache_cluster.redis[0].cache_nodes[0].port}" : "not created"
}
