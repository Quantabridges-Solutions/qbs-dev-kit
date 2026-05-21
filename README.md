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
├── cursor/
│   ├── rules/          # .mdc rules for Cursor AI agent
│   └── skills/         # Agent skills for Cursor (~/.cursor/skills/)
├── claude/
│   ├── CLAUDE.global.md   # Global context for Claude Code (~/.claude/CLAUDE.md)
│   ├── CLAUDE.project.md  # Per-project CLAUDE.md template
│   ├── rules/          # .md rules for Claude Code (~/.claude/rules/)
│   └── skills/         # Agent skills for Claude Code (~/.claude/skills/)
├── templates/
│   ├── docker/         # docker-compose.yml, Dockerfiles, nginx.conf
│   ├── github-actions/ # Deploy Lambda, deploy S3/CloudFront, .NET test, iOS build
│   ├── gitignore/      # Full-stack .gitignore
│   ├── terraform/      # Lambda, CloudFront/S3, RDS, variables, outputs
│   └── sdd/            # Spec / plan / tasks / checklist / constitution templates (SDD)
├── scripts/
│   └── sdd/            # `new-feature.sh` — bootstrap `specs/NNN-slug/`
├── docs/               # Setup guides and reference documentation
└── install.sh          # Interactive installer
```

### AI Rules (9 topics)

| Rule | Scope | Covers |
|------|-------|--------|
| `saas-global` | Always | Project layout, OTP auth, multi-tenancy, naming |
| `security` | Always | JWT, encryption, tenant isolation, CORS, rate limiting |
| `dotnet-api-services` | `src/backend/**/*.cs` | Traditional services architecture |
| `dotnet-api-cqrs` | `src/backend/**/*.cs` | CQRS/MediatR architecture |
| `postgres-efcore` | `src/backend/**/*.cs` | Code-first migrations, DbContext, entities |
| `react-web` | `src/frontend/**/*.{ts,tsx}` | Vite, TanStack Query, Axios, Tailwind |
| `react-native` | `src/mobile/**/*.{ts,tsx}` | Expo Router, SecureStore, OTP, navigation |
| `terraform-aws` | `**/*.tf` | Lambda, API Gateway, S3, CloudFront, RDS |
| `github-actions` | `.github/workflows/*.yml` | Secrets, deploy patterns, migration step |
| `docker` | `docker-compose*.yml` | Service naming, healthchecks, Dockerfiles |

### AI Skills (7 skills)

| Skill | Trigger | Does |
|-------|---------|------|
| `scaffold-saas-project` | "new project", "scaffold" | Creates full project structure, copies all rules and templates |
| `dotnet-services-feature` | "add feature", "new endpoint" | Scaffolds entity + DTOs + service + controller + migration |
| `dotnet-cqrs-feature` | "add feature" (CQRS projects) | Scaffolds command + query + handlers + controller |
| `react-web-saas` | "new page", "add component" | Page + API hook + TanStack Query + routing |
| `react-native-expo` | "new screen", "mobile feature" | Expo Router screen + navigation + API integration |
| `aws-saas-infra` | "terraform", "deploy", "Lambda" | First-time setup, resource additions, manual deploy |
| `saas-security-review` | "security review", "is this secure" | 10-point checklist + encryption + OTP templates |
| `qbs-sdd-feature` | "spec-driven", "SDD", "feature spec", "plan before code" | Phased workflow: constitution → spec → plan → tasks → implement under `specs/NNN-slug/` |

---

## Quick Start

### 1. Install the kit

```bash
git clone https://github.com/Quantabridges-Solutions/qbs-dev-kit.git ~/source/qbs-dev-kit
bash ~/source/qbs-dev-kit/install.sh
```

The installer will ask:
1. **Which AI provider?** — Cursor / Claude Code / Both
2. **Which .NET pattern?** — Traditional Services (default) or CQRS/MediatR
3. **Target project path?** — Optional: drop rules directly into an existing project

### 2. Start a new project

Open Cursor or Claude Code in your workspace and say:

> "Scaffold a new SaaS project called [name]"

The `scaffold-saas-project` skill will guide the agent through the full setup.

### 3. Add rules to an existing project

```bash
bash ~/source/qbs-dev-kit/install.sh
# When prompted for project path, enter your project directory
```

This drops the appropriate rules into `.cursor/rules/` and `.claude/rules/` and creates a `CLAUDE.md` template.

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
