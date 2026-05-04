resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  lambda_function_name = "${var.project_name}-api-${var.environment}"
  frontend_bucket      = "${var.project_name}-frontend-${var.environment}-${random_id.suffix.hex}"
}
