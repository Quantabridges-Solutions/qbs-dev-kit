# Getting Started

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| [Cursor](https://cursor.sh) or [Claude Code](https://code.claude.com) | Latest | AI coding agent |
| [.NET SDK](https://dotnet.microsoft.com/download) | 8.0 or 10.0 | Backend development |
| [Node.js](https://nodejs.org) | 20+ | Frontend / mobile |
| [pnpm](https://pnpm.io) | 9+ | Package manager |
| [Docker Desktop](https://www.docker.com/products/docker-desktop) | Latest | Local full-stack |
| [Terraform CLI](https://developer.hashicorp.com/terraform/install) | 1.6+ | AWS infrastructure |
| [AWS CLI](https://aws.amazon.com/cli/) | v2 | AWS deployment |
| [EAS CLI](https://expo.dev/eas) | Latest | Mobile builds |

---

## Step 1 — Clone the kit

Clone it wherever you like and keep the checkout — `install.sh` records its path in `~/.config/qbs-dev-kit/kit-root` so scaffold can find templates after skills are copied to `~/.cursor/skills`.

```bash
git clone https://github.com/Quantabridges-Solutions/qbs-dev-kit.git ~/source/qbs-dev-kit
```

Override anytime with `export QBS_KIT_ROOT=/path/to/qbs-dev-kit`.

---

## Step 2 — Run the installer

```bash
bash ~/source/qbs-dev-kit/install.sh
```

Non-interactive:

```bash
bash ~/source/qbs-dev-kit/install.sh --yes --provider both --dotnet services
bash ~/source/qbs-dev-kit/install.sh --project ~/source/my-app --yes
bash ~/source/qbs-dev-kit/install.sh --dry-run --yes
bash ~/source/qbs-dev-kit/install.sh --uninstall
```

Interactive prompts (skipped with `--yes`):

**1. Which AI provider?** Cursor / Claude Code / Both (default)

**2. Which .NET architecture?** Traditional Services (default) or CQRS/MediatR

**3. Project path?** Optional — installs rules, hooks, `AGENTS.md`, and `CLAUDE.md`

The installer then:

- Copies canonical `skills/` into `~/.cursor/skills/` and/or `~/.claude/skills/`
- Copies Cursor rules to `~/.cursor/rules/` (and Claude rules to `~/.claude/rules/`)
- Installs `~/.claude/CLAUDE.md`

---

## Step 3 — Start a new project

Create an empty folder, open it in the agent, and say:

> Scaffold a new SaaS project called [your project name]

If you do **not** name components, the skill asks **once** which to include (`all` / `api` / `frontend` / `mobile` / `api+frontend` / `api+mobile`), then runs `scripts/scaffold.sh` and the language toolchains with no further questions.

Defaults unless you override them in the prompt:

- AWS region: `eu-west-1`
- Components: asked once; Enter → `all`
- .NET pattern: Traditional Services

Examples:

> Scaffold a new SaaS project called invoice-flow, CQRS pattern, no mobile  
> `@~/.cursor/skills/scaffold-saas-project/SKILL.md` scaffold payroll-hub, api+frontend only

---

## Spec-driven features (optional)

For non-trivial work, use **`qbs-sdd-feature`**: constitution → specify → clarify → plan → checklist → tasks → **analyze** → implement → **converge**. See [Spec-driven development (SDD)](sdd-workflow.md).

---

## Step 4 — Local development

```bash
cd your-project
cp .env.example .env   # DB_PASSWORD, JWT_KEY, RESEND_API_KEY
docker compose up
```

- API: `http://localhost:5075`
- Frontend: `http://localhost:3000`
- API docs (Scalar): `http://localhost:5075/scalar`
- Email capture: `http://localhost:5050`
- Health: `http://localhost:5075/health`

---

## Step 5 — First-time AWS deployment

> Set up the AWS infrastructure for this project

`aws-saas-infra` walks through Terraform. Optional Redis: `create_elasticache = true` (needs VPC + private subnets, same as RDS).

---

## Optional companion skills (not vendored here)

```bash
npx skills add hashicorp/agent-skills --skill terraform-style-guide
npx skills add vercel-labs/agent-skills --skill react-best-practices
```

Keep QBS skills for OTP, `OrganizationId`, and Lambda; use those for HCL/React style.

---

## Keeping the kit updated

```bash
cd "$QBS_KIT_ROOT"   # or the path in ~/.config/qbs-dev-kit/kit-root
git pull
bash install.sh --yes
```
