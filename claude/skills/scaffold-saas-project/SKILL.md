---
name: scaffold-saas-project
description: Scaffold a new QBS SaaS project from scratch. Creates the full directory structure, copies standard templates (gitignore, docker-compose, GitHub Actions, Terraform), and installs Claude rules.
when_to_use: Use when starting a new SaaS product or platform, or when the user says "new project", "scaffold", "bootstrap", or "start a new app".
disable-model-invocation: true
---

# Scaffold QBS SaaS Project

## What this does
Sets up the full standard project structure for a new SaaS product:
- Directory layout (`src/backend`, `src/frontend`, `src/mobile`, `infra/terraform`)
- Standard config files (`.gitignore`, `.cursorignore`, `.env.example`)
- `docker-compose.yml` for local full-stack dev
- GitHub Actions workflows (Lambda deploy, S3 deploy, dotnet test)
- Terraform infra templates (Lambda, CloudFront/S3, RDS)
- `.claude/rules/` with all technology rules pre-installed

## Steps

### 1. Gather project info
Ask the user for:
- `project_name` (e.g. `invoice-flow`, `legal-aid`)
- `aws_region` (default: `eu-west-1`)
- Which components are needed: API? Frontend? Mobile? All three?
- .NET architecture pattern: **Traditional Services** (default) or **CQRS/MediatR**

### 2. Create directory structure
```bash
mkdir -p src/{backend,frontend,mobile}
mkdir -p infra/terraform/scripts
mkdir -p .github/workflows
mkdir -p .cursor/rules
mkdir -p scripts
mkdir -p documents
```

### 3. Copy Claude rules
Copy all rules from `qbs-standards/claude/rules/` to `.claude/rules/`:
- `saas-global.md` (always)
- `dotnet-api-services.md` → saved as `dotnet-api.md` (Traditional Services — default)
  OR `dotnet-api-cqrs.md` → saved as `dotnet-api.md` (CQRS — if user chose it)
- `postgres-efcore.md` (if has API)
- `react-web.md` (if has frontend)
- `react-native.md` (if has mobile)
- `terraform-aws.md` (if has infra)
- `github-actions.md` (always)
- `docker.md` (always)

Copy `qbs-standards/claude/CLAUDE.project.md` to project root as `CLAUDE.md`, fill in project name.

**Source:** `~/source/quantabridges/qbs-standards/claude/`

### 4. Create standard files

**.gitignore** — combine relevant sections:
```
# .NET
bin/ obj/ *.user *.suo .vs/

# Node / React
node_modules/ dist/ .pnpm-store/

# Expo / React Native
.expo/ web-build/ ios/build/ android/.gradle/ android/build/

# Terraform
.terraform/ *.tfstate *.tfstate.backup terraform.tfvars tfplan

# Environment
.env .env.local .env.production

# macOS
.DS_Store

# Logs
*.log
```

**.cursorignore**:
```
**/node_modules/
**/.pnpm-store/
**/bin/
**/obj/
**/out/
**/dist/
**/TestResults/
**/*.log
.cache/
**/.expo/
**/web-build/
**/Pods/
**/ios/build/
**/android/.gradle/
**/android/**/build/
.git/
infra/terraform/.terraform/
infra/terraform/*.tfstate
infra/terraform/*.tfstate.backup
```

**.env.example**:
```
DB_PASSWORD=ChangeMe123!
JWT_KEY=your-jwt-secret-here-min-32-chars
RESEND_API_KEY=re_xxx
AWS_REGION=eu-west-1
```

### 5. Create docker-compose.yml
Use the template from `qbs-standards/templates/docker/docker-compose.yml`, replacing `{project}` with `project_name`.

### 6. Create terraform files
Copy files from `qbs-standards/templates/terraform/` to `infra/terraform/`.
Update `variables.tf` default values with the project name.

### 7. Create GitHub Actions workflows
Copy from `qbs-standards/templates/github-actions/` to `.github/workflows/`.
Add a `GITHUB_SECRETS.md` listing all required secrets.

### 8. Create README.md
```markdown
# {Project Name}

SaaS platform — API (AWS Lambda), Web (CloudFront/S3), Mobile (Expo).

## Local development
cp .env.example .env
# Edit .env with real values
docker-compose up

## Stack
- Backend: .NET 8, EF Core, PostgreSQL, Redis, JWT (AWS Lambda)
- Frontend: React 19, Vite, TypeScript, Tailwind CSS (S3 + CloudFront)
- Mobile: React Native, Expo (EAS)
- Infra: Terraform (AWS)

## Deployment
See `.github/workflows/` — push to `main` auto-deploys.
See `infra/terraform/README.md` for first-time setup.
```

### 9. Initialise git
```bash
git init
git add .
git commit -m "chore: initial project scaffold"
```

## Output confirmation
Tell the user:
- What was created
- Next steps: fill `.env`, run `docker-compose up`, then `dotnet new webapi` in `src/backend`
- Link to `qbs-standards` for reference
