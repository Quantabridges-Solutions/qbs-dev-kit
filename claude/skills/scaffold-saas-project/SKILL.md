---
name: scaffold-saas-project
description: "QBS SaaS scaffold. READ this file fully before doing anything. Ask ONE question (which components?), then execute all scaffolding steps immediately with no further questions. Defaults: .NET 8, React+Vite, Expo, Postgres, eu-west-1, Traditional Services."
when_to_use: Use when starting a new SaaS product or platform, or when the user says "new project", "scaffold", "bootstrap", or "start a new app".
disable-model-invocation: true
---

# Scaffold QBS SaaS Project

> **AGENT INSTRUCTION: Read this file fully. Ask the ONE required question in Step 1, wait for the answer, then execute ALL remaining steps immediately without any further questions.**

## Steps

### 1. Ask ONE question — then execute immediately

Before doing anything else, ask:

> "Which components do you need for **{project_name}**?
>
> - `all` — API + Frontend + Mobile *(default)*
> - `api` — .NET backend only
> - `frontend` — React web only
> - `mobile` — Expo mobile only
> - `api+frontend` — no mobile
> - `api+mobile` — no frontend
>
> Press Enter for `all`."

Wait for the answer. Then proceed immediately — no more questions.

Set variables:
- `NEED_API` = true if response includes `api` or `all`
- `NEED_FRONTEND` = true if response includes `frontend` or `all`
- `NEED_MOBILE` = true if response includes `mobile` or `all`
- `aws_region` = `eu-west-1` (unless user mentioned otherwise)
- `dotnet_arch` = Traditional Services (unless user said CQRS)

---

### 2. Base directory structure + config files

```bash
mkdir -p infra/terraform/scripts
mkdir -p .github/workflows
mkdir -p .claude/rules
mkdir -p .cursor/rules
mkdir -p scripts
mkdir -p documents
mkdir -p specs templates/sdd scripts/sdd docs

[ "$NEED_API" = true ]      && mkdir -p src/backend
[ "$NEED_FRONTEND" = true ] && mkdir -p src/frontend
[ "$NEED_MOBILE" = true ]   && mkdir -p src/mobile
```

Copy standard config files from the kit:
```bash
KIT=~/source/quantabridges/qbs-dev-kit

cp "$KIT/templates/gitignore/saas-full.gitignore" .gitignore
cp "$KIT/templates/cursorignore"                  .cursorignore
```

Copy SDD (spec-driven development) templates and helper script:
```bash
cp "$KIT/docs/sdd-workflow.md" docs/
cp "$KIT/templates/sdd/"*.md templates/sdd/
cp "$KIT/scripts/sdd/new-feature.sh" scripts/sdd/
chmod +x scripts/sdd/new-feature.sh
cp "$KIT/templates/sdd/constitution-template.md" docs/qbs-constitution.md
```

Replace the `{TODAY}` placeholder in `docs/qbs-constitution.md` with today's ISO date (e.g. `2026-05-21`).


Create `.env.example`:
```
DB_PASSWORD=ChangeMe123!
JWT_KEY=your-jwt-secret-here-min-32-chars
RESEND_API_KEY=re_xxx
AWS_REGION={aws_region}
```

---

### 3. Copy rules

**Claude rules** → `.claude/rules/`:
```bash
KIT_RULES=~/source/quantabridges/qbs-dev-kit/claude/rules

cp "$KIT_RULES/saas-global.md"       .claude/rules/
cp "$KIT_RULES/github-actions.md"    .claude/rules/
cp "$KIT_RULES/docker.md"            .claude/rules/
[ "$NEED_API" = true ]      && cp "$KIT_RULES/postgres-efcore.md"  .claude/rules/
[ "$NEED_FRONTEND" = true ] && cp "$KIT_RULES/react-web.md"        .claude/rules/
[ "$NEED_MOBILE" = true ]   && cp "$KIT_RULES/react-native.md"     .claude/rules/
                               cp "$KIT_RULES/terraform-aws.md"    .claude/rules/
```

For .NET architecture:
```bash
# Traditional Services (default):
cp "$KIT_RULES/dotnet-api-services.md" .claude/rules/dotnet-api.md

# CQRS (if user specified):
cp "$KIT_RULES/dotnet-api-cqrs.md" .claude/rules/dotnet-api.md
```

**Cursor rules** → `.cursor/rules/` (same pattern, `.mdc` extension):
```bash
CKIIT=~/source/quantabridges/qbs-dev-kit/cursor/rules
cp "$CKIIT/saas-global.mdc"    .cursor/rules/
cp "$CKIIT/github-actions.mdc" .cursor/rules/
cp "$CKIIT/docker.mdc"         .cursor/rules/
[ "$NEED_API" = true ]      && cp "$CKIIT/postgres-efcore.mdc" .cursor/rules/
[ "$NEED_FRONTEND" = true ] && cp "$CKIIT/react-web.mdc"       .cursor/rules/
[ "$NEED_MOBILE" = true ]   && cp "$CKIIT/react-native.mdc"    .cursor/rules/
                               cp "$CKIIT/terraform-aws.mdc"   .cursor/rules/
```

**Project CLAUDE.md:**
```bash
cp ~/source/quantabridges/qbs-dev-kit/claude/CLAUDE.project.md CLAUDE.md
# Replace project name placeholder with {project_name}
```

---

### 4. Scaffold backend — if NEED_API

PascalCase the project name (e.g. `service-hub` → `ServiceHub`) for .NET namespaces. Use `{PascalName}` below.

```bash
cd src/backend

dotnet new sln -n {PascalName}
dotnet new webapi       -n {PascalName}.Api            -o {PascalName}.Api
dotnet new classlib     -n {PascalName}.Application    -o {PascalName}.Application
dotnet new classlib     -n {PascalName}.Domain         -o {PascalName}.Domain
dotnet new classlib     -n {PascalName}.Infrastructure -o {PascalName}.Infrastructure
dotnet sln add **/*.csproj

dotnet add {PascalName}.Api/{PascalName}.Api.csproj \
  reference {PascalName}.Application/{PascalName}.Application.csproj
dotnet add {PascalName}.Application/{PascalName}.Application.csproj \
  reference {PascalName}.Domain/{PascalName}.Domain.csproj
dotnet add {PascalName}.Infrastructure/{PascalName}.Infrastructure.csproj \
  reference {PascalName}.Domain/{PascalName}.Domain.csproj
dotnet add {PascalName}.Api/{PascalName}.Api.csproj \
  reference {PascalName}.Infrastructure/{PascalName}.Infrastructure.csproj

dotnet add {PascalName}.Infrastructure package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add {PascalName}.Infrastructure package Microsoft.EntityFrameworkCore.Relational
dotnet add {PascalName}.Api package Microsoft.EntityFrameworkCore.Design
dotnet add {PascalName}.Api package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add {PascalName}.Api package Scalar.AspNetCore
dotnet add {PascalName}.Api package StackExchange.Redis

cd ../..
```

Copy Dockerfile:
```bash
cp ~/source/quantabridges/qbs-dev-kit/templates/docker/Dockerfile.api src/backend/Dockerfile
```

---

### 5. Scaffold frontend — if NEED_FRONTEND

```bash
cd src/frontend

pnpm create vite@latest . -- --template react-ts
pnpm install
pnpm add -D tailwindcss @tailwindcss/vite

cd ../..
```

Update `src/frontend/vite.config.ts`:
```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [
    react(),
    tailwindcss(),
  ],
})
```

Replace `src/frontend/src/index.css` with:
```css
@import "tailwindcss";
```

Copy Docker support files:
```bash
cp ~/source/quantabridges/qbs-dev-kit/templates/docker/Dockerfile.frontend src/frontend/Dockerfile
cp ~/source/quantabridges/qbs-dev-kit/templates/docker/nginx.conf           src/frontend/nginx.conf
```

---

### 6. Scaffold mobile — if NEED_MOBILE

```bash
cd src/mobile
npx create-expo-app@latest . --template blank-typescript
cd ../..
```

---

### 7. docker-compose.yml

```bash
sed "s/{project}/{project_name}/g" \
  ~/source/quantabridges/qbs-dev-kit/templates/docker/docker-compose.yml \
  > docker-compose.yml
```

---

### 8. Terraform files

```bash
TF_SRC=~/source/quantabridges/qbs-dev-kit/templates/terraform
cp "$TF_SRC"/*.tf      infra/terraform/
cp "$TF_SRC"/*.example infra/terraform/
```

Update `infra/terraform/variables.tf` — replace the default project name placeholder with `{project_name}`.

---

### 9. GitHub Actions workflows

```bash
GH_SRC=~/source/quantabridges/qbs-dev-kit/templates/github-actions
[ "$NEED_API" = true ]      && cp "$GH_SRC/deploy-api-lambda.yml"  .github/workflows/
[ "$NEED_FRONTEND" = true ] && cp "$GH_SRC/deploy-frontend-s3.yml" .github/workflows/
[ "$NEED_MOBILE" = true ]   && cp "$GH_SRC/mobile-ios-build.yml"   .github/workflows/
cp "$GH_SRC/dotnet-test.yml" .github/workflows/
```

Create `GITHUB_SECRETS.md`:
```markdown
# Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | IAM deploy user key |
| `AWS_SECRET_ACCESS_KEY` | IAM deploy user secret |
| `AWS_REGION` | e.g. `eu-west-1` |
| `DB_PASSWORD` | RDS database password |
| `JWT_KEY` | JWT signing secret (min 32 chars) |
| `RESEND_API_KEY` | Resend email API key |
| `EXPO_TOKEN` | EAS build token (mobile only) |
```

---

### 10. README.md

```markdown
# {Project Name}

> SaaS platform — API (AWS Lambda) · Web (CloudFront/S3) · Mobile (Expo)

## Quick start
cp .env.example .env   # fill in DB_PASSWORD, JWT_KEY, RESEND_API_KEY
docker-compose up

## Services (local)
| Service | URL |
|---------|-----|
| API | http://localhost:5075 |
| API docs (Scalar) | http://localhost:5075/scalar |
| Health check | http://localhost:5075/health |
| Frontend | http://localhost:3000 |
| Email capture (Mailpit) | http://localhost:5050 |

## Stack
- **Backend** — .NET 8, EF Core, PostgreSQL, Redis, JWT · deployed as AWS Lambda
- **Frontend** — React 19, Vite, TypeScript, Tailwind CSS · hosted on S3 + CloudFront
- **Mobile** — React Native, Expo · built with EAS
- **Infra** — Terraform (AWS)

## Deployment
Push to `main` → GitHub Actions auto-deploys.
See `infra/terraform/README.md` for first-time AWS setup.
See `GITHUB_SECRETS.md` for required secrets.
```

---

### 11. Initialise git

```bash
git init
git add .
git commit -m "chore: initial project scaffold"
```

---

## Output confirmation

Tell the user which components were scaffolded, then:

**Next steps:**
1. Fill in `.env` (copy from `.env.example`)
2. Run `docker-compose up` to start Postgres + Redis + Mailpit
3. Run the API: `cd src/backend && dotnet run --project {PascalName}.Api`
4. Run the frontend: `cd src/frontend && pnpm dev`
5. Run mobile: `cd src/mobile && npx expo start`
6. When ready to deploy: fill `GITHUB_SECRETS.md` secrets into GitHub repo settings
