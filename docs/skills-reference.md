# Skills Reference

Skills are loaded on demand. Canonical copies live in this repo under `skills/`. `install.sh` copies them to the provider folders below.

| Provider | Location |
|----------|----------|
| Cursor | `~/.cursor/skills/` |
| Claude Code | `~/.claude/skills/` |

`name` in each `SKILL.md` matches the folder (Agent Skills spec). Run `bash scripts/validate-skills.sh` to check.

---

## scaffold-saas-project

**Triggers:** "new project", "scaffold", "bootstrap", "start a new app"

Asks **once** which components to include (unless you already said), then runs `skills/scaffold-saas-project/scripts/scaffold.sh` (copies rules, Terraform, workflows, hooks, `AGENTS.md`, SDD templates) and the language toolchains (`dotnet new`, Vite, Expo).

Kit path: `QBS_KIT_ROOT` or `~/.config/qbs-dev-kit/kit-root`.

---

## qbs-sdd-feature

**Triggers:** "spec-driven", "SDD", "spec kit", "analyze", "converge"

Phases: constitution → specify → clarify → plan → checklist → tasks → **analyze** → implement → **converge**. Optional tasks → GitHub issues.

One phase per message unless you ask for a full run. Analyze is read-only; converge only appends to `tasks.md`.

`./scripts/sdd/new-feature.sh <slug>` creates `specs/NNN-slug/` including `analyze.md`.

---

## dotnet-services-feature *(default)*

Entity + DTOs + service + thin controller + `OrganizationId` filter + `dotnet ef migrations add`.

---

## dotnet-cqrs-feature

Domain entity + commands/queries/handlers/validators + controller. Folder name and skill `name` are both `dotnet-cqrs-feature`.

---

## react-web-saas

Page, route, TanStack Query, shared axios client, OTP login/verify patterns.

---

## react-native-expo

Expo Router screen, SecureStore JWT, OTP screens, tabs.

---

## aws-saas-infra

Terraform first-time setup, Lambda/API Gateway, S3/CloudFront, optional RDS and **ElastiCache Redis** (`create_elasticache`).

---

## saas-security-review

10-point checklist (auth, tenancy, PII, secrets, logs, CORS, AWS). Use before ship.

---

## qbs-test-feature

xUnit + `WebApplicationFactory` tenant isolation tests; Playwright/Vitest on the web app.

---

## qbs-code-review

PR/diff review against QBS never-list. Not a substitute for `saas-security-review`.

---

## qbs-observability

Correlation IDs, Serilog compact JSON, CloudWatch-friendly logs. No tokens/OTP/PII in logs.

---

## eas-release

EAS `eas.json`, iOS + Android CI templates, store submit. Requires `EXPO_TOKEN`.

---

## Optional companions (do not copy into this kit)

```bash
npx skills add hashicorp/agent-skills --skill terraform-style-guide
npx skills add vercel-labs/agent-skills --skill react-best-practices
```
