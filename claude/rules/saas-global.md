---
description: Global QBS SaaS conventions — project layout, auth, multi-tenancy, and naming
alwaysApply: true
---

# QBS SaaS Global Standards

## Project layout
```
src/
  backend/          # .NET 8 API
  frontend/         # React (Vite + TypeScript)
  mobile/           # React Native (Expo)
infra/terraform/    # AWS infrastructure
.github/workflows/  # CI/CD
docker-compose.yml  # Local full-stack
```

## Authentication — OTP only
- No password-based auth; all login and signup flows use OTP (email or SMS)
- JWT issued after successful OTP verification
- JWT carries `sub` (userId) and `orgId` (tenantId)

## Multi-tenancy
- Every tenant-scoped entity carries `OrganizationId` (GUID)
- Backend filters ALL data queries by `OrganizationId` via `ICurrentOrganization`
- Never return cross-tenant data; fail loudly if `OrganizationId` is missing

## Naming conventions
- .NET: PascalCase classes, methods; camelCase fields
- TypeScript: PascalCase components; camelCase functions/variables; kebab-case files
- Database: snake_case tables and columns
- Terraform resources: snake_case, prefixed `{project_name}-{resource}-{env}`
- GitHub secrets: SCREAMING_SNAKE_CASE

## Environments
| Name | Host | Purpose |
|------|------|---------|
| `Development` | local docker-compose | daily dev, no AWS costs |
| `Staging` | AWS (mirrors production) | QA, test data, safe to break |
| `Production` | AWS | real users, real data |

- `ASPNETCORE_ENVIRONMENT` / `NODE_ENV` control behaviour — never use `#if DEBUG` in business logic
- Staging and production are separate AWS accounts or at least separate Terraform workspaces
- Staging auto-deploys on every push to `main`; production requires a manual approval gate in GitHub Actions

## Soft deletes
- Soft-deletable entities extend `SoftDeleteEntity : BaseEntity` (adds `IsDeleted`, `DeletedAtUtc?`)
- EF Core global query filter: `.HasQueryFilter(e => !e.IsDeleted)` — soft-deleted rows invisible by default
- Hard deletes only for GDPR erasure requests; log the hard delete with userId + timestamp

## Standard API error format (RFC 7807 ProblemDetails)
```json
{ "type": "https://tools.ietf.org/html/rfc7807", "title": "Validation failed",
  "status": 400, "detail": "Email is required", "traceId": "00-abc..." }
```
- Use `app.UseExceptionHandler()` + `IProblemDetailsService` — never expose raw stack traces
- Validation errors (FluentValidation) return `status 422` with `errors` extension field
- Auth failures: `401 Unauthorized`; missing permissions: `403 Forbidden`; not found: `404 Not Found`

## Never
- Never commit `.env` files — use `.env.example`
- Never hard-code secrets or connection strings in source
- Never write EF Core migration files by hand — always use `dotnet ef migrations add`
- Never bypass the API client (create ad-hoc fetch/axios instances)
- Never store JWT in `localStorage` for sensitive apps — use `HttpOnly` cookies (web) or `SecureStore` (mobile)
- Never log tokens, OTP codes, passwords, or PII
- Never use `AllowAnyOrigin()` in production CORS configuration
- Never expose OrganizationId or internal IDs in API responses unless required
