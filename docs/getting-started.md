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

```bash
git clone https://github.com/Quantabridges-Solutions/qbs-dev-kit.git ~/source/qbs-dev-kit
```

Keep it here permanently — the installer references this path, and you can `git pull` to get updates.

---

## Step 2 — Run the installer

```bash
bash ~/source/qbs-dev-kit/install.sh
```

You'll be asked three questions:

**1. Which AI provider?**
```
1) Cursor only
2) Claude Code only
3) Both Cursor + Claude Code   ← recommended
```

**2. Which .NET architecture pattern?**
```
1) Traditional Services  ← recommended (Controllers → Services → DbContext)
2) CQRS / MediatR
```

**3. Which project to drop rules into? (optional)**
Enter the full path to an existing project to install rules directly, or press Enter to skip.

The installer then:
- Copies skills to `~/.cursor/skills/` and/or `~/.claude/skills/`
- Copies rules to `~/.claude/rules/` (Claude global rules)
- Installs `~/.claude/CLAUDE.md` (global Claude context)

---

## Step 3 — Start a new project

Create an empty folder for your project, open it in Cursor (Agent mode), and use this exact prompt — the `@` reference forces Cursor to load the skill before acting:

> `@~/.cursor/skills/scaffold-saas-project/SKILL.md scaffold a new SaaS project called [your project name]`

The skill will immediately scaffold the full project — no questions asked. It uses these defaults unless you specify otherwise:
- AWS region: `eu-west-1`
- Components: API + Frontend + Mobile (all three)
- .NET pattern: Traditional Services

To override a default, add it to your prompt, e.g.:  
> `@~/.cursor/skills/scaffold-saas-project/SKILL.md scaffold a new SaaS project called invoice-flow, CQRS pattern, no mobile`

---

## Step 4 — Local development

Once scaffolded:

```bash
cd your-project

# Copy and fill environment variables
cp .env.example .env
# Edit .env — set DB_PASSWORD, JWT_KEY, RESEND_API_KEY

# Start everything
docker-compose up
```

Services available at:
- API: `http://localhost:5075`
- Frontend: `http://localhost:3000`
- API docs (Scalar): `http://localhost:5075/scalar`
- Email capture: `http://localhost:5050`
- Health check: `http://localhost:5075/health`

---

## Step 5 — First-time AWS deployment

See [AWS Infrastructure Setup](cursor-setup.md#aws) or ask your AI agent:

> "Set up the AWS infrastructure for this project"

The `aws-saas-infra` skill will walk through Terraform init, plan, and apply, and tell you which values to set as GitHub secrets.

---

## Keeping the kit updated

```bash
cd ~/source/qbs-dev-kit
git pull
bash install.sh
```

Re-running the installer updates all installed skills and rules automatically.
