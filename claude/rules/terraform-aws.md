---
description: Terraform AWS infrastructure — Lambda, API Gateway, S3, CloudFront, RDS, and conventions
globs: {infra,terraform}/**/*.tf
alwaysApply: false
---

# Terraform AWS Standards

## Standard stack per SaaS product
| Component | AWS Service |
|-----------|------------|
| API | Lambda (dotnet8) + API Gateway HTTP v2 |
| Frontend | S3 (private) + CloudFront (OAC) |
| Database | RDS PostgreSQL (or Aurora Serverless v2) |
| Secrets | Lambda env vars via `var.lambda_environment` |

## File layout
```
infra/terraform/
  providers.tf        # AWS provider + region
  versions.tf         # Terraform + provider version constraints
  backend.tf.example  # Remote state template (never commit actual backend.tf)
  variables.tf        # All var declarations + descriptions
  locals.tf           # Derived names (bucket, function name, etc.)
  lambda_api.tf       # Lambda + API Gateway
  s3_cloudfront.tf    # Frontend hosting
  rds.tf              # Database (when applicable)
  outputs.tf          # Exported values (API URL, CF domain, etc.)
  terraform.tfvars    # Actual values — gitignored
  scripts/
    plan              # terraform plan wrapper
    apply             # terraform apply wrapper
```

## Naming convention
```hcl
locals {
  lambda_function_name = "${var.project_name}-api-${var.environment}"
  frontend_bucket      = "${var.project_name}-frontend-${var.environment}-${random_id.suffix.hex}"
}
```

## Lambda bootstrap pattern
- Terraform provisions a placeholder zip bundle
- Real code deployed via GitHub Actions (`aws lambda update-function-code`)
- `lifecycle { ignore_changes = [filename, source_code_hash, s3_bucket, s3_key] }`

## CloudFront SPA routing
```hcl
custom_error_response {
  error_code         = 403
  response_code      = 200
  response_page_path = "/index.html"
}
custom_error_response {
  error_code         = 404
  response_code      = 200
  response_page_path = "/index.html"
}
```

## Remote state (required for team projects)
```hcl
terraform {
  backend "s3" {
    bucket = "{project}-tfstate"
    key    = "{env}/terraform.tfstate"
    region = "eu-west-1"
  }
}
```

## Required variables
```hcl
variable "project_name"  {}  # e.g. "invoiceflow"
variable "environment"   {}  # "staging" | "production"
variable "aws_region"    {}
variable "lambda_environment" { type = map(string) }
```

## Security
- S3 bucket: always `block_public_acls = true`, use OAC (not OAI)
- CloudFront: `viewer_protocol_policy = "redirect-to-https"`
- Lambda: minimal IAM role (AWSLambdaBasicExecutionRole + specific permissions only)
- Never put secrets in tfvars committed to git
