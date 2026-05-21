# QBS SaaS Development Standards

I build SaaS platforms for Quantabridges Solutions. Every project follows these conventions.

## Standard stack

| Layer | Technology | Hosting |
|-------|-----------|---------|
| API | .NET 8/10, EF Core, PostgreSQL, Redis, JWT | AWS Lambda |
| Frontend | React 19, Vite, TypeScript, Tailwind CSS v4 | S3 + CloudFront |
| Mobile | React Native, Expo (Expo Router) | EAS (iOS/Android) |
| Database | PostgreSQL 16 | RDS or local Docker |
| Infra | Terraform | AWS |
| CI/CD | GitHub Actions | GitHub |

## Project layout (always)
```
src/backend/        .NET API
src/frontend/       React web app
src/mobile/         React Native Expo app
infra/terraform/    AWS infrastructure
.github/workflows/  CI/CD pipelines
docker-compose.yml  Local full-stack dev
```

## Hard rules — always follow

1. **OTP-only auth** — no password logins; JWT issued after OTP verification
2. **Multi-tenant** — every entity scoped by `OrganizationId`; never leak cross-tenant data
3. **No hand-written EF migrations** — always `dotnet ef migrations add` then `dotnet ef database update`
4. **No .env commits** — use `.env.example` with placeholders
5. **No ad-hoc HTTP clients** — one axios instance per app, one `api` export
6. **Thin controllers** — no business logic; delegate to services or handlers
7. **Build after .NET changes** — always run `dotnet build` and `dotnet test` when touching services/domain
8. **pnpm** for web/mobile package management; `npm` only when forced

## .NET architecture preference
**Traditional Services** (default): Controllers → IXxxService → XxxService → AppDbContext
CQRS/MediatR: only when the project already uses it

## Debugging / bug fix format
When fixing bugs, deliver:
- Root cause
- Files changed
- Code diff
- Regression checklist

## Spec-driven features (brownfield)
For non-trivial work, follow **SDD**: keep artifacts under `specs/NNN-slug/` (`spec.md` → clarify → `plan.md` → `tasks.md` → implement). Read `docs/qbs-constitution.md` before planning. Human guide: `docs/sdd-workflow.md`. Skill: `qbs-sdd-feature`.

