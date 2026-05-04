---
description: GitHub Actions CI/CD — workflow patterns, secrets, and deployment conventions
paths:
  - .github/workflows/*.yml
---

# GitHub Actions Standards

## Standard workflows
| File | Trigger | Purpose |
|------|---------|---------|
| `deploy-api-lambda.yml` | push `src/backend/**` → main | Build, publish, zip, update Lambda |
| `deploy-frontend-s3.yml` | push `src/frontend/**` → main | Build Vite, sync S3, invalidate CF |
| `dotnet-test.yml` | push/PR `src/backend/**` | Restore, build, test |
| `mobile-ios-build.yml` | push `src/mobile/**` → main | EAS build + submit |

## Required GitHub secrets
```
AWS_ACCESS_KEY_ID · AWS_SECRET_ACCESS_KEY · AWS_REGION
LAMBDA_FUNCTION_NAME · FRONTEND_S3_BUCKET · CLOUDFRONT_DISTRIBUTION_ID
VITE_API_URL · DATABASE_CONNECTION_STRING (optional)
```

## Workflow skeleton
```yaml
on:
  push:
    branches: [main]
    paths:
      - 'src/backend/**'
      - '.github/workflows/deploy-api-lambda.yml'
  workflow_dispatch:

permissions:
  contents: read
```

## EF Core migration step (always optional — skip if secret absent)
```yaml
- name: Apply EF migrations
  env:
    ConnectionStrings__DefaultConnection: ${{ secrets.DATABASE_CONNECTION_STRING }}
  run: |
    [ -z "${ConnectionStrings__DefaultConnection:-}" ] && echo "Skipping" && exit 0
    dotnet tool install --global dotnet-ef --version 8.0.11
    export PATH="$PATH:$HOME/.dotnet/tools"
    dotnet ef database update \
      --project {Project}.Infrastructure/{Project}.Infrastructure.csproj \
      --startup-project {Project}.API/{Project}.API.csproj
```

## Conventions
- Use `actions/checkout@v4`, `actions/setup-dotnet@v4`, `actions/setup-node@v4`
- Always add `paths:` filter; include workflow file itself in the filter
- Never hardcode tool versions — use `'8.0.x'` format
