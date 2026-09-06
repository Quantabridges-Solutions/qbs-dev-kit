# Rules Reference

Rules give the AI agent persistent knowledge about your stack. They load automatically when you work on matching files — you never need to re-explain conventions.

## Rule locations after install

| Format | Location | Loaded by |
|--------|----------|-----------|
| `.mdc` | `~/.cursor/rules/` (user) and `.cursor/rules/` (project) | Cursor |
| `.md` | `.claude/rules/` (per project or `~/.claude/rules/` globally) | Claude Code |

---

## saas-global

**Always active — no file pattern required**

Covers the project layout convention, authentication model, multi-tenancy pattern, naming conventions, and a list of hard "never do" rules.

Key points enforced:
- `src/backend/`, `src/frontend/`, `src/mobile/`, `infra/terraform/` layout
- OTP-only authentication, no passwords
- Every tenant entity has `OrganizationId`
- Never commit `.env` files or secrets
- pnpm for all Node projects

---

## security

**Always active — no file pattern required**

The most important always-on rule. Covers the full security surface of a SaaS application.

Key points enforced:
- JWT max 60-minute expiry; OTP 10-minute expiry, single-use, hashed
- Every endpoint must have explicit `[Authorize]`
- Every tenant query must filter by `OrganizationId` from server context (not request body)
- PII fields encrypted at column level via EF Core value converters
- No secrets in source, config files, or committed tfvars
- CORS: explicit origins only, never `AllowAnyOrigin()` in production
- Rate limiting on all auth endpoints
- Never log tokens, OTP codes, or PII

---

## dotnet-api-services *(default)*

**Active when:** `src/backend/**/*.cs`

Traditional services architecture — the pattern used in all QBS production projects.

```
Controller → IXxxService → XxxService → AppDbContext
```

Enforces thin controllers, service interfaces, DTO/model separation, EF Core code-first migrations, Serilog logging, health checks at `/health`, and Scalar docs at `/scalar`.

---

## dotnet-api-cqrs

**Active when:** `src/backend/**/*.cs`

MediatR-based CQRS architecture for projects that use it.

```
Controller → IMediator → CommandHandler / QueryHandler → Repository
```

Enforces Domain/Application/Infrastructure/API layer separation, command and query DTOs as records, FluentValidation pipeline behaviours.

---

## postgres-efcore

**Active when:** `src/backend/**/*.cs`

EF Core + PostgreSQL conventions. The single most important rule: **never hand-write migration files**.

Migration commands:
```bash
dotnet ef migrations add <Name> --project Infrastructure --startup-project Api
dotnet ef database update --project Infrastructure --startup-project Api
```

Also covers: `BaseEntity` pattern, `IEntityTypeConfiguration<T>` per entity, `SaveChangesAsync` auto-updating `UpdatedAtUtc`.

---

## react-web

**Active when:** `src/frontend/**/*.ts`, `src/frontend/**/*.tsx`

React 19 + Vite + TypeScript + Tailwind CSS v4. Enforces a single axios client (`src/api/client.ts`), TanStack Query for all server state, query keys that include `orgId` for tenant-scoped data, functional components only, no `any` types.

---

## react-native

**Active when:** `src/mobile/**/*.ts`, `src/mobile/**/*.tsx`

Expo managed workflow with Expo Router. Enforces `Expo.SecureStore` for token storage (never `AsyncStorage` for auth), OTP-based login/verify flow, splash screen setup, `StyleSheet.create` for styles.

---

## terraform-aws

**Active when:** `infra/**/*.tf`, `terraform/**/*.tf`

Standard AWS stack: Lambda (dotnet8) + API Gateway HTTP v2, S3 + CloudFront (OAC), RDS PostgreSQL, optional ElastiCache Redis. Enforces naming convention (`{project}-{resource}-{env}`), Lambda placeholder bootstrap pattern, SPA CloudFront routing, HTTPS-only, private S3, VPC for Lambda when RDS or Redis is enabled, minimal IAM.

---

## github-actions

**Active when:** `.github/workflows/*.yml`

Standard workflow patterns for Lambda deploy, S3/CloudFront deploy, .NET test, frontend test, Terraform plan, and EAS iOS + Android builds. Enforces path filters on all workflows, the optional EF migration step pattern, and required secret names.

---

## docker

**Active when:** `docker-compose*.yml`

Service naming (`{project}-db`, `{project}-api`, `{project}-frontend`), healthcheck requirements, service dependency order, standard ports (5432 Postgres, 6379 Redis, 5075 API, 3000 Frontend, 5050 smtp4dev).
