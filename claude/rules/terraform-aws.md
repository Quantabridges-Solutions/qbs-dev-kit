---
description: Terraform AWS infrastructure — Lambda, API Gateway, S3, CloudFront, RDS conventions
paths:
  - infra/**/*.tf
  - terraform/**/*.tf
---

# Terraform AWS Standards

## Standard stack per SaaS product
| Component | AWS Service |
|-----------|------------|
| API | Lambda (dotnet8) + API Gateway HTTP v2 |
| Frontend | S3 (private) + CloudFront (OAC) |
| Database | RDS PostgreSQL 16 |

## File layout
```
infra/terraform/
  providers.tf · versions.tf · backend.tf.example
  variables.tf · locals.tf · outputs.tf
  lambda_api.tf · s3_cloudfront.tf · rds.tf
  terraform.tfvars (gitignored)
```

## Naming convention
```hcl
locals {
  lambda_function_name = "${var.project_name}-api-${var.environment}"
  frontend_bucket      = "${var.project_name}-frontend-${var.environment}-${random_id.suffix.hex}"
}
```

## Lambda bootstrap pattern
- Terraform provisions a placeholder zip
- Real code deployed via GitHub Actions (`aws lambda update-function-code`)
- `lifecycle { ignore_changes = [filename, source_code_hash, s3_bucket, s3_key] }`

## CloudFront SPA routing (required)
```hcl
custom_error_response { error_code = 403; response_code = 200; response_page_path = "/index.html" }
custom_error_response { error_code = 404; response_code = 200; response_page_path = "/index.html" }
```

## After `terraform apply` — set GitHub secrets
```bash
terraform output api_url              # → VITE_API_URL + Lambda base
terraform output lambda_function_name # → LAMBDA_FUNCTION_NAME
terraform output frontend_bucket      # → FRONTEND_S3_BUCKET
terraform output cloudfront_id        # → CLOUDFRONT_DISTRIBUTION_ID
```

## Security
- S3: always `block_public_acls = true`, use OAC (not OAI)
- CloudFront: `viewer_protocol_policy = "redirect-to-https"`
- Lambda: minimal IAM (AWSLambdaBasicExecutionRole + specific only)
- Secrets in `lambda_environment` variable — never in committed tfvars
