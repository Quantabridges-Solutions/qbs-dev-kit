# {Project Name}

{One-line description of what this SaaS product does.}

## Stack
- **Backend**: .NET 8, EF Core, PostgreSQL, Redis, JWT — hosted on AWS Lambda
- **Frontend**: React 19, Vite, TypeScript, Tailwind CSS v4 — hosted on S3/CloudFront
- **Mobile**: React Native, Expo — distributed via EAS
- **Infra**: Terraform (AWS), GitHub Actions

## Project structure
```
src/backend/{ProjectName}.API/        API project
src/backend/{ProjectName}.Domain/     Entities and interfaces
src/backend/{ProjectName}.Infrastructure/ DbContext, repos, caching, email
src/frontend/                         Vite + React app
src/mobile/                           Expo app
infra/terraform/                      AWS resources
```

## Build and run

```bash
# Local full stack
cp .env.example .env   # fill in values
docker-compose up

# Backend only
cd src/backend && dotnet run --project {ProjectName}.API

# Frontend only
cd src/frontend && pnpm install && pnpm run dev

# Mobile
cd src/mobile && pnpm install && npx expo start
```

## Test
```bash
cd src/backend && dotnet test
cd src/frontend && pnpm run test
```

## Migrations
```bash
dotnet ef migrations add <Name> \
  --project src/backend/{ProjectName}.Infrastructure/{ProjectName}.Infrastructure.csproj \
  --startup-project src/backend/{ProjectName}.API/{ProjectName}.API.csproj

dotnet ef database update \
  --project src/backend/{ProjectName}.Infrastructure/{ProjectName}.Infrastructure.csproj \
  --startup-project src/backend/{ProjectName}.API/{ProjectName}.API.csproj
```

## Environment variables
See `.env.example` — copy to `.env` for local dev.
Lambda env vars are set via `var.lambda_environment` in `infra/terraform/terraform.tfvars`.

## Deployment
Push to `main` → GitHub Actions auto-deploys:
- `src/backend/**` changes → Lambda deploy
- `src/frontend/**` changes → S3 sync + CloudFront invalidation

First-time infra setup: see `infra/terraform/README.md`.

## Key URLs (after deploy)
- API: `terraform output api_url`
- App: `terraform output cloudfront_domain`

## Spec-driven development (optional)

Feature specs and plans live under `specs/NNN-slug/` (`spec.md`, `plan.md`, `tasks.md`). See `docs/sdd-workflow.md`. Bootstrap a folder with `./scripts/sdd/new-feature.sh <slug>`. Principles: `docs/qbs-constitution.md`.

## Notes
<!-- Add project-specific context here that Claude should know every session -->
<!-- Examples: external API quirks, business rules, special auth flows, known issues -->

Also see `AGENTS.md` (Cursor/Codex) — keep the two files aligned on layout and hard rules.
