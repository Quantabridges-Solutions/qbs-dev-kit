---
description: Global QBS SaaS conventions — project layout, auth, multi-tenancy, and naming
---

# QBS SaaS Global Standards

## Project layout
```
src/
  backend/          # .NET API
  frontend/         # React (Vite + TypeScript)
  mobile/           # React Native (Expo)
infra/terraform/    # AWS infrastructure
.github/workflows/  # CI/CD
docker-compose.yml  # Local full-stack
```

## Authentication — OTP only
- No password-based auth; all login and signup use OTP (email or SMS)
- JWT issued after successful OTP verification
- JWT carries `sub` (userId) and `orgId` (tenantId)

## Multi-tenancy
- Every tenant-scoped entity carries `OrganizationId` (GUID)
- Backend filters ALL data queries by `OrganizationId` via `ICurrentOrganization`
- Never return cross-tenant data; fail loudly if `OrganizationId` is missing

## Naming conventions
- .NET: PascalCase classes/methods; camelCase fields
- TypeScript: PascalCase components; camelCase functions/variables; kebab-case files
- Database: snake_case tables and columns
- Terraform resources: snake_case, prefixed `{project_name}-{resource}-{env}`
- GitHub secrets: SCREAMING_SNAKE_CASE

## Never
- Never commit `.env` files — use `.env.example`
- Never hard-code secrets or connection strings in source
- Never write EF Core migration files by hand — always use `dotnet ef migrations add`
- Never bypass the API client (create ad-hoc fetch/axios instances)
- Never store JWT in `localStorage` for sensitive apps — use `HttpOnly` cookies (web) or `SecureStore` (mobile)
- Never log tokens, OTP codes, passwords, or PII
- Never use `AllowAnyOrigin()` in production CORS configuration
