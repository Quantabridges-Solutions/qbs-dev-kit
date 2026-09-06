# QBS Dev Kit

[![License: CC BY-ND 4.0](https://img.shields.io/badge/License-CC%20BY--ND%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nd/4.0/)
[![Cursor](https://img.shields.io/badge/Cursor-Compatible-blue?logo=cursor)](https://cursor.sh)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-orange?logo=anthropic)](https://code.claude.com)
[![.NET](https://img.shields.io/badge/.NET-8%20%2F%2010-purple?logo=dotnet)](https://dotnet.microsoft.com)
[![Terraform](https://img.shields.io/badge/Terraform-AWS-623CE4?logo=terraform)](https://terraform.io)

**An AI-powered development accelerator for SaaS platforms** — built and maintained by [Quantabridges Solutions](https://github.com/Quantabridges-Solutions).

---

## What is this?

QBS Dev Kit is a collection of **AI agent rules**, **skills**, and **project templates** that eliminate the repetitive setup work in building SaaS products. Instead of reconfiguring Cursor or Claude Code for every new project, or copying boilerplate across repos, this kit gives your AI agent persistent knowledge of your full stack from day one.

Every new project starts production-ready with:
- Clean architecture conventions enforced automatically
- Security rules active on every session
- AWS infrastructure templates proven in production
- GitHub Actions workflows ready to deploy
- Docker environment wired and working

---

## Standard Stack

| Layer | Technology | Hosting |
|-------|-----------|---------|
| API | .NET 8/10, EF Core, PostgreSQL, JWT | AWS Lambda |
| Frontend | React 19, Vite, TypeScript, Tailwind CSS v4 | S3 + CloudFront |
| Mobile | React Native, Expo (Expo Router) | EAS (iOS/Android) |
| Database | PostgreSQL 16 | RDS or Docker |
| Cache | Redis | ElastiCache or Docker |
| Infrastructure | Terraform | AWS |
| CI/CD | GitHub Actions | — |

---

## What's Included

```
qbs-dev-kit/
├── skills/                 # Canonical Agent Skills (copied to Cursor + Claude)
├── cursor/rules/           # .mdc rules for Cursor
├── claude/
│   ├── CLAUDE.global.md
│   ├── CLAUDE.project.md
│   └── rules/
├── templates/
│   ├── docker/
│   ├── github-actions/     # Lambda, S3/CloudFront, tests, EAS iOS+Android, Terraform plan
│   ├── terraform/          # Lambda, CloudFront/S3, RDS, ElastiCache, variables
│   ├── sdd/                # Spec, plan, tasks, checklist, analyze, constitution
│   ├── hooks/              # Cursor hooks (secrets + tenant filter)
│   └── agents/             # AGENTS.md template
├── scripts/
│   ├── sdd/new-feature.sh
│   ├── scaffold-project.sh
│   └── validate-skills.sh
├── .cursor-plugin/         # Cursor Plugin manifest (team marketplace)
├── plugin.json             # Open Agent Plugin (skills)
└── install.sh              # Interactive or `--yes` installer
```

### AI Rules (10 topics)

| Rule | Scope | Covers |
|------|-------|--------|
| `saas-global` | Always | Project layout, OTP auth, multi-tenancy, naming |
| `security` | Always | JWT, encryption, tenant isolation, CORS, rate limiting |
| `dotnet-api-services` | `src/backend/**/*.cs` | Traditional services architecture |
| `dotnet-api-cqrs` | `src/backend/**/*.cs` | CQRS/MediatR architecture |
| `postgres-efcore` | `src/backend/**/*.cs` | Code-first migrations, DbContext, entities |
| `react-web` | `src/frontend/**/*.{ts,tsx}` | Vite, TanStack Query, Axios, Tailwind |
| `react-native` | `src/mobile/**/*.{ts,tsx}` | Expo Router, SecureStore, OTP, navigation |
| `terraform-aws` | `**/*.tf` | Lambda, API Gateway, S3, CloudFront, RDS, ElastiCache, variables |
| `github-actions` | `.github/workflows/*.yml` | Secrets, deploy patterns, migration step |
| `docker` | `docker-compose*.yml` | Service naming, healthchecks, Dockerfiles |

### AI Skills

| Skill | Trigger | Does |
|-------|---------|------|
| `scaffold-saas-project` | "new project", "scaffold" | Copies kit files via `scripts/scaffold.sh`, then language toolchains |
| `dotnet-services-feature` | "add feature", "new endpoint" | Entity + DTOs + service + controller + EF CLI migration |
| `dotnet-cqrs-feature` | "add feature" (CQRS projects) | Command + query + handlers + controller |
| `react-web-saas` | "new page", "add component" | Page + API hook + TanStack Query + routing |
| `react-native-expo` | "new screen", "mobile feature" | Expo Router screen + navigation + API |
| `aws-saas-infra` | "terraform", "deploy", "Lambda" | First-time setup, RDS/Redis, manual deploy |
| `saas-security-review` | "security review", "is this secure" | 10-point checklist + encryption + OTP templates |
| `qbs-sdd-feature` | "spec-driven", "SDD", "analyze", "converge" | Constitution → spec → plan → analyze → implement → converge |
| `qbs-test-feature` | "add tests", "Playwright", "tenant isolation" | xUnit WebApplicationFactory + frontend tests |
| `qbs-code-review` | "review this PR", "code review" | QBS convention review (OTP, OrganizationId, EF CLI) |
| `qbs-observability` | "logging", "correlation id", "CloudWatch" | Serilog + correlation IDs for Lambda |
| `eas-release` | "EAS", "Play Store", "App Store" | iOS + Android EAS build/submit |

---

## Quick Start

### 1. Install the kit

```bash
git clone https://github.com/Quantabridges-Solutions/qbs-dev-kit.git ~/source/qbs-dev-kit
bash ~/source/qbs-dev-kit/install.sh --yes
# or interactive: bash ~/source/qbs-dev-kit/install.sh
```

Non-interactive flags: `--provider cursor|claude|both` `--dotnet services|cqrs` `--project PATH` `--dry-run` `--uninstall`.

### 2. Start a new project

Open Cursor or Claude Code in your workspace and say:

> "Scaffold a new SaaS project called [name]"

The `scaffold-saas-project` skill will guide the agent through the full setup.

### 3. Add rules to an existing project

```bash
bash ~/source/qbs-dev-kit/install.sh
# When prompted for project path, enter your project directory
```

This drops rules into `.cursor/rules/` and `.claude/rules/`, Cursor hooks, `AGENTS.md`, and a `CLAUDE.md` template.

---

## Guides

- [Getting Started](docs/getting-started.md)
- [Cursor Setup](docs/cursor-setup.md)
- [Claude Code Setup](docs/claude-setup.md)
- [Rules Reference](docs/rules-reference.md)
- [Skills Reference](docs/skills-reference.md)
- [Spec-driven development (SDD)](docs/sdd-workflow.md)

---

## Architecture Principles

- **OTP-only authentication** — no password-based login
- **Multi-tenant by default** — every entity scoped by `OrganizationId`
- **Code-first DB migrations** — `dotnet ef migrations add` only, never hand-written
- **Thin controllers** — business logic lives in services, not controllers
- **Single API client** — one axios instance per app, never ad-hoc
- **Security first** — rules enforce JWT expiry, CORS restrictions, rate limiting, PII encryption, and no secrets in code

---

## License

This project is licensed under the [Creative Commons Attribution-NoDerivatives 4.0 International License](LICENSE).

You are free to:
- **Use** this kit in your own projects
- **Fork** this repository for personal reference

You may not:
- **Modify** and redistribute the kit as your own
- **Sublicense** or sell the kit commercially

© 2026 [Quantabridges Solutions](https://github.com/Quantabridges-Solutions). All rights reserved.
