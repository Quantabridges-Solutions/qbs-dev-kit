variable "project_name" {
  description = "Short project identifier used in resource names (e.g. invoiceflow)"
  type        = string
}

variable "environment" {
  description = "Deployment environment: staging | production"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "environment must be 'staging' or 'production'."
  }
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-west-1"
}

# ── Lambda ────────────────────────────────────────────────────────────────────

variable "lambda_memory_mb" {
  description = "Lambda function memory in MB"
  type        = number
  default     = 512
}

variable "lambda_timeout_seconds" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_environment" {
  description = "Environment variables passed to the Lambda function"
  type        = map(string)
  sensitive   = true
  default     = {}
}

# ── CloudFront ────────────────────────────────────────────────────────────────

variable "cloudfront_price_class" {
  description = "CloudFront price class (PriceClass_100 = US/Europe only)"
  type        = string
  default     = "PriceClass_100"
}
