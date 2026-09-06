---
name: aws-saas-infra
description: Manage AWS infrastructure for a QBS SaaS project using Terraform. Covers first-time setup, adding resources (Lambda, CloudFront, RDS, ElastiCache/Redis, S3), deployments, and troubleshooting. Use when the user mentions Terraform, AWS, Lambda, CloudFront, RDS, Redis, ElastiCache, infra setup, or deployment infrastructure.
license: CC-BY-ND-4.0
---

# AWS SaaS Infrastructure (Terraform)

## First-time project setup
```bash
cd infra/terraform

# 1. Copy backend config (configure S3 remote state)
cp backend.tf.example backend.tf
# Edit backend.tf with your S3 bucket + key

# 2. Copy and fill vars
cp terraform.tfvars.example terraform.tfvars
# Edit: project_name, environment, aws_region, lambda_environment

# 3. Create S3 bucket for remote state first (one-time)
aws s3 mb s3://{project}-tfstate --region {region}
aws s3api put-bucket-versioning --bucket {project}-tfstate --versioning-configuration Status=Enabled

# 4. Init and apply
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Standard infra files location
```
infra/terraform/
  providers.tf       # aws provider + region
  versions.tf        # version constraints
  backend.tf.example # remote state template
  variables.tf       # all input variables
  locals.tf          # derived names
  lambda_api.tf      # Lambda + API Gateway HTTP v2
  s3_cloudfront.tf   # Frontend: S3 + CloudFront (OAC)
  rds.tf             # PostgreSQL RDS (optional; set create_rds)
  elasticache.tf     # Redis (optional; set create_elasticache)
  outputs.tf         # API URL, CF domain, bucket name, Redis endpoint
  terraform.tfvars   # actual values (gitignored)
```

## After provisioning — get outputs
```bash
terraform output api_url              # set as VITE_API_URL + LAMBDA_FUNCTION_NAME secret
terraform output cloudfront_domain    # app URL
terraform output frontend_bucket      # set as FRONTEND_S3_BUCKET secret
terraform output cloudfront_id        # set as CLOUDFRONT_DISTRIBUTION_ID secret
terraform output lambda_function_name # set as LAMBDA_FUNCTION_NAME secret
terraform output redis_endpoint       # set ConnectionStrings__Redis when create_elasticache = true
```

## Required GitHub secrets (set these after `terraform apply`)
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
LAMBDA_FUNCTION_NAME           ← terraform output lambda_function_name
FRONTEND_S3_BUCKET             ← terraform output frontend_bucket
CLOUDFRONT_DISTRIBUTION_ID     ← terraform output cloudfront_id
VITE_API_URL                   ← terraform output api_url
DATABASE_CONNECTION_STRING      ← from RDS outputs (optional)
```

## Set Lambda environment variables
```bash
# Via Terraform (preferred): add to var.lambda_environment in tfvars
lambda_environment = {
  "ConnectionStrings__DefaultConnection" = "Host=...;..."
  "Jwt__Key"                             = "your-secret-key"
  "Resend__ApiKey"                       = "re_xxx"
}

# Or via AWS CLI (quick fix)
aws lambda update-function-configuration \
  --function-name {function-name} \
  --environment "Variables={KEY=value}"
```

## Deploy API manually (bypass GitHub Actions)
```bash
cd src/backend/{Project}.API
dotnet publish -c Release -r linux-x64 --self-contained false -o /tmp/lambda-publish
cd /tmp/lambda-publish && zip -qr /tmp/lambda.zip .
aws lambda update-function-code \
  --function-name {function-name} \
  --zip-file fileb:///tmp/lambda.zip
aws lambda wait function-updated-v2 --function-name {function-name}
```

## Deploy frontend manually
```bash
cd src/frontend
VITE_API_URL=https://xxx.execute-api.region.amazonaws.com pnpm run build
aws s3 sync dist/ s3://{bucket}/ --delete \
  --cache-control "public,max-age=31536000,immutable" \
  --exclude "index.html"
aws s3 cp dist/index.html s3://{bucket}/index.html \
  --cache-control "public,max-age=0,must-revalidate"
aws cloudfront create-invalidation \
  --distribution-id {cf-id} --paths "/*"
```

## Teardown (staging only)
```bash
terraform destroy
```
**Never destroy production without explicit confirmation.**

## Adding a new Terraform resource
1. Create a new `.tf` file (e.g. `ses.tf` for email, `sns.tf` for SMS)
2. Add required variables to `variables.tf`
3. Add outputs to `outputs.tf`
4. Add IAM permissions to the Lambda role if needed
5. Run `terraform plan` to verify before `apply`
