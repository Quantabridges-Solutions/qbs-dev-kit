# Skills Reference

Skills are loaded on demand — they only consume context when invoked, keeping the AI fast and focused. You can trigger them naturally or explicitly.

## Skill locations after install

| Provider | Location |
|----------|----------|
| Cursor | `~/.cursor/skills/` |
| Claude Code | `~/.claude/skills/` |

---

## scaffold-saas-project

**Triggers:** "new project", "scaffold", "bootstrap", "start a new app"

**What it does:**

Walks the agent through creating a full SaaS project from scratch:

1. Creates `src/backend/`, `src/frontend/`, `src/mobile/`, `infra/terraform/`, `.github/workflows/`
2. Asks: project name, AWS region, which components (API / Frontend / Mobile / All)
3. Asks: Traditional Services or CQRS for .NET
4. Copies the correct cursor rules to `.cursor/rules/` and Claude rules to `.claude/rules/`
5. Creates `.gitignore`, `.cursorignore`, `.env.example`, `docker-compose.yml`
6. Copies GitHub Actions workflows and Terraform templates
7. Creates `README.md` with project-specific content
8. Initialises git with an initial commit

**Example prompt:**
> "Scaffold a new SaaS project called `payroll-hub` on AWS eu-west-1"

---

## dotnet-services-feature *(default)*

**Triggers:** "add feature", "new endpoint", "create entity", "add [EntityName] to the API"

**What it does:**

Scaffolds the complete vertical slice for a new feature using Traditional Services:

- `Models/{Entity}.cs` — EF entity extending BaseEntity
- `DTOs/{Entity}/` — `{Entity}Dto.cs`, `Create{Entity}Dto.cs`, `Update{Entity}Dto.cs`
- `Services/Interfaces/I{Entity}Service.cs` — service contract
- `Services/{Entity}Service.cs` — full CRUD implementation with `OrganizationId` filtering
- `Controllers/{Entity}Controller.cs` — thin controller (GET list, GET by id, POST, PUT, DELETE)
- Adds DbSet to `AppDbContext`
- Registers service in DI
- Runs `dotnet ef migrations add Add{Entity}` + `dotnet ef database update`

**Example prompt:**
> "Add an Expense entity with CRUD endpoints"

---

## dotnet-cqrs-feature

**Triggers:** Same as above, for projects using CQRS/MediatR

**What it does:**

Scaffolds Domain entity + Application Commands/Queries/Handlers/Validators + API Controller.

---

## react-web-saas

**Triggers:** "new page", "add page", "add component", "dashboard section", "web UI feature"

**What it does:**

Creates a new page or feature in the React web app:

- `src/pages/{Feature}Page.tsx` — page component with TanStack Query hooks
- `src/api/{domain}.ts` — API functions for this domain
- Route added to router config
- Navigation link added to sidebar/nav
- Optional: form with React Hook Form + Zod validation
- Optional: data table with TanStack Table

Follows OTP auth patterns for login/verify pages when building auth flows.

**Example prompt:**
> "Add an Expenses page with a table and a form to create expenses"

---

## react-native-expo

**Triggers:** "new screen", "mobile feature", "add [screen] to the app", "Expo screen"

**What it does:**

Creates a new screen in the Expo Router app:

- `app/(app)/{screen}.tsx` — screen component
- API integration via the centralized axios client
- Navigation integration (tab bar or stack)
- Handles OTP auth screens (`/(auth)/login`, `/(auth)/verify`) with SecureStore
- Profile screen with org switcher and logout
- Splash screen configuration when setting up the root layout

**Example prompt:**
> "Add an expenses screen to the mobile app with a list and pull-to-refresh"

---

## aws-saas-infra

**Triggers:** "terraform", "AWS setup", "Lambda deploy", "CloudFront", "infra setup", "first-time deployment"

**What it does:**

Guides through AWS infrastructure management:

- **First-time setup:** creates S3 remote state bucket, `terraform init`, `plan`, `apply`
- **After apply:** outputs the values to set as GitHub secrets
- **Setting Lambda env vars:** via `terraform.tfvars` or AWS CLI
- **Manual deploy:** `dotnet publish` → zip → `aws lambda update-function-code`
- **Manual frontend deploy:** Vite build → S3 sync → CloudFront invalidation
- **Adding resources:** new `.tf` files with correct naming, IAM permissions, outputs

**Example prompt:**
> "Set up the AWS infrastructure for this project for the first time"

---

## saas-security-review

**Triggers:** "security review", "is this secure", "security check", "review this endpoint", handling of sensitive data

**What it does:**

Runs a 10-point security checklist against a feature or endpoint:

1. Authentication & authorization on every endpoint
2. Multi-tenant data isolation (OrganizationId double-check)
3. Input validation coverage
4. PII identification and encryption
5. Secrets management audit
6. Log scanning for sensitive data leaks
7. API surface (CORS, HTTPS, rate limiting, headers)
8. Frontend/mobile token storage
9. AWS infrastructure hardening
10. Audit trail for sensitive mutations

Includes ready-to-paste code for:
- AES-256 column-level encryption via EF Core value converters
- Hashed OTP code storage and verification with BCrypt
- Encryption key generation (`openssl rand -base64 32`)

**Example prompt:**
> "Do a security review of the new payments endpoint"
> "Is this feature secure before I ship it?"
