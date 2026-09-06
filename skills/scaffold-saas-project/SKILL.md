---
name: scaffold-saas-project
description: "Scaffold a QBS SaaS project (API + React + Expo + Terraform). Ask ONE question (which components?) unless the user already specified them, then run scripts/scaffold.sh and language toolchains with no further questions. Defaults: .NET 8, React+Vite, Expo, Postgres, eu-west-1, Traditional Services. Use when the user says new project, scaffold, bootstrap, or start a new app."
license: CC-BY-ND-4.0
---

# Scaffold QBS SaaS Project

Read this file fully. Ask the ONE question in Step 1 only if components were not specified. Then run the script and remaining toolchain steps with no further questions.

## Defaults

- AWS region: `eu-west-1` (unless the user named another)
- Components: `all` if they press Enter / omit
- .NET: Traditional Services unless they said CQRS / MediatR
- Kit checkout: `QBS_KIT_ROOT` or `~/.config/qbs-dev-kit/kit-root` (written by `install.sh`)

## Step 1 — components

If the user did **not** already name components, ask once:

> Which components for **{project_name}**? `all` (default) · `api` · `frontend` · `mobile` · `api+frontend` · `api+mobile`

Then continue immediately.

## Step 2 — copy kit files

Run the bundled script from this skill directory (works after install.sh):

```bash
SKILL_DIR="$HOME/.cursor/skills/scaffold-saas-project"
# Claude Code: $HOME/.claude/skills/scaffold-saas-project
# Or this skill folder inside the kit checkout: $QBS_KIT_ROOT/skills/scaffold-saas-project

bash "$SKILL_DIR/scripts/scaffold.sh" \
  --name "{project_name}" \
  --components "{all|api|frontend|mobile|api+frontend|api+mobile}" \
  --dotnet "{services|cqrs}" \
  --region "{aws_region}" \
  --out "{project_root}"
```

If the script cannot find the kit, set `QBS_KIT_ROOT` to the qbs-dev-kit git checkout and re-run.

## Step 3 — language toolchains (after the script)

PascalCase `{project_name}` → `{PascalName}` (e.g. `service-hub` → `ServiceHub`).

### Backend — if NEED_API

```bash
cd src/backend
dotnet new sln -n {PascalName}
dotnet new webapi       -n {PascalName}.Api            -o {PascalName}.Api
dotnet new classlib     -n {PascalName}.Application    -o {PascalName}.Application
dotnet new classlib     -n {PascalName}.Domain         -o {PascalName}.Domain
dotnet new classlib     -n {PascalName}.Infrastructure -o {PascalName}.Infrastructure
dotnet sln add **/*.csproj
dotnet add {PascalName}.Api/{PascalName}.Api.csproj reference {PascalName}.Application/{PascalName}.Application.csproj
dotnet add {PascalName}.Application/{PascalName}.Application.csproj reference {PascalName}.Domain/{PascalName}.Domain.csproj
dotnet add {PascalName}.Infrastructure/{PascalName}.Infrastructure.csproj reference {PascalName}.Domain/{PascalName}.Domain.csproj
dotnet add {PascalName}.Api/{PascalName}.Api.csproj reference {PascalName}.Infrastructure/{PascalName}.Infrastructure.csproj
dotnet add {PascalName}.Infrastructure package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add {PascalName}.Infrastructure package Microsoft.EntityFrameworkCore.Relational
dotnet add {PascalName}.Api package Microsoft.EntityFrameworkCore.Design
dotnet add {PascalName}.Api package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add {PascalName}.Api package Scalar.AspNetCore
dotnet add {PascalName}.Api package StackExchange.Redis
cd ../..
```

### Frontend — if NEED_FRONTEND

```bash
cd src/frontend
pnpm create vite@latest . -- --template react-ts
pnpm install
pnpm add -D tailwindcss @tailwindcss/vite
cd ../..
```

Add the Tailwind Vite plugin to `vite.config.ts` and `@import "tailwindcss";` in `src/index.css`.

### Mobile — if NEED_MOBILE

```bash
cd src/mobile
npx create-expo-app@latest . --template blank-typescript
cd ../..
```

## Step 4 — git

```bash
git init
git add .
git commit -m "chore: initial project scaffold"
```

Skip if the directory is already a git repo with commits.

## Confirm

List what was created. Next steps for the user: fill `.env` from `.env.example`, `docker compose up`, run API/frontend/mobile, set GitHub secrets from `GITHUB_SECRETS.md`.
