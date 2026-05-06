---
description: GitHub Actions CI/CD — workflow patterns, secrets, and deployment conventions
globs: .github/workflows/*.yml
alwaysApply: false
---

# GitHub Actions Standards

## Standard workflows per SaaS product
| File | Trigger | Purpose |
|------|---------|---------|
| `deploy-api-lambda.yml` | push `src/backend/**` → main | Build, publish, zip, update Lambda |
| `deploy-frontend-s3.yml` | push `src/frontend/**` → main | Build Vite, sync S3, invalidate CF |
| `dotnet-test.yml` | push/PR `src/backend/**` | Restore, build, test |
| `mobile-ios-build.yml` | push `src/mobile/**` → main | EAS build + submit |

## Required secrets (set at repo level)
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
LAMBDA_FUNCTION_NAME
FRONTEND_S3_BUCKET
CLOUDFRONT_DISTRIBUTION_ID
VITE_API_URL
DATABASE_CONNECTION_STRING     # optional — enables CI migration step
```

## Workflow structure
```yaml
name: Deploy API to AWS Lambda
on:
  push:
    branches: [main]
    paths:
      - 'src/backend/**'
      - '.github/workflows/deploy-api-lambda.yml'
  workflow_dispatch:

permissions:
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: src/backend
```

## EF Core migration step (Lambda workflow)
```yaml
- name: Apply EF Core migrations
  env:
    ConnectionStrings__DefaultConnection: ${{ secrets.DATABASE_CONNECTION_STRING }}
  run: |
    if [ -z "${ConnectionStrings__DefaultConnection:-}" ]; then
      echo "Skipping — DATABASE_CONNECTION_STRING not set"
      exit 0
    fi
    dotnet tool install --global dotnet-ef --version 8.0.11
    export PATH="$PATH:$HOME/.dotnet/tools"
    dotnet ef database update \
      --project {Project}.Infrastructure/{Project}.Infrastructure.csproj \
      --startup-project {Project}.API/{Project}.API.csproj
```

## Path filters
- Always add `paths:` filter to avoid unnecessary runs
- Include the workflow file itself in its own path filter

## Mobile builds
- Use EAS (Expo Application Services) via `expo-github-action`
- Requires `EXPO_TOKEN` secret
- Build profiles: `development`, `preview`, `production` in `eas.json`

## Conventions
- Use `actions/checkout@v4`, `actions/setup-dotnet@v4`, `actions/setup-node@v4`
- Cache dependencies (pnpm lockfile, .NET restore)
- Never hardcode versions — use `'8.0.x'` format for flexibility
