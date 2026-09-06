---
name: qbs-code-review
description: Review a PR or local diff against QBS SaaS conventions — OTP-only auth, OrganizationId filters, thin controllers, EF CLI migrations, single API client, no secrets. Use when the user asks for a code review, PR review, review my changes, or a pre-merge checklist (not a full security audit — use saas-security-review for that).
license: CC-BY-ND-4.0
---

# QBS code review

Review **this branch vs the base** (`git diff origin/main...HEAD` or the uncommitted diff). Stay defect-first. Do not rewrite style that already matches the repo.

## Format

```
- root cause (or “no blocking issues”)
- files
- severity: blocking | should-fix | nit
- regression checklist
```

## Blocking

- Missing `[Authorize]` (or undocumented `[AllowAnonymous]`) on new endpoints
- Tenant query without `OrganizationId` from `ICurrentOrganization` (including `FindAsync(id)` alone)
- Password-based auth or JWT in `localStorage`
- Hand-written `Migrations/*.cs` (must be `dotnet ef migrations add`)
- Secrets, connection strings, or OTP codes in source or logs
- Ad-hoc axios/fetch instead of the shared API client
- `AllowAnyOrigin()` in production CORS
- Fat controllers (business logic not in services/handlers)

## Should-fix

- No FluentValidation on new input DTOs
- New tenant entity without a tenant-isolation test (`qbs-test-feature`)
- Missing ProblemDetails / 422 validation mapping
- Frontend page without org-scoped query keys
- Terraform resource without encryption / least-privilege IAM

## Out of scope

Full 10-point security checklist → `saas-security-review`. Infra first-time apply → `aws-saas-infra`.

## Regression checklist (always include)

- [ ] `dotnet build` / `dotnet test` if API changed
- [ ] `pnpm run build` if frontend changed
- [ ] Tenant isolation still holds for touched entities
