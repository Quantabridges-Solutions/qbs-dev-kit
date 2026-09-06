# {Project Name}

SaaS product using the QBS stack. Agents: follow this file plus `.cursor/rules/` / `.claude/rules/` and `docs/qbs-constitution.md`.

## Layout

- `src/backend/` — .NET API (EF Core, PostgreSQL, JWT after OTP)
- `src/frontend/` — React (Vite + TypeScript + Tailwind)
- `src/mobile/` — React Native (Expo Router)
- `infra/terraform/` — AWS (Lambda, API Gateway, S3, CloudFront, RDS, ElastiCache)
- `specs/NNN-slug/` — spec-driven feature artifacts
- `.github/workflows/` — CI/CD

## Hard rules

- OTP-only authentication — no password login
- Tenant-scoped data always filters by `OrganizationId` from server context (`ICurrentOrganization`), never from the request body
- Never hand-write EF Core migrations — `dotnet ef migrations add` only
- Thin controllers — business logic in services (or CQRS handlers)
- One API client per app — no ad-hoc fetch/axios instances
- Never commit `.env`, secrets, or `terraform.tfvars`
- JWT: HttpOnly cookies (web) or SecureStore (mobile), not `localStorage`

## Commands

```bash
docker compose up
cd src/backend && dotnet test
cd src/frontend && pnpm test
./scripts/sdd/new-feature.sh <slug>
```

Fill in project-specific build/test commands after scaffold.
