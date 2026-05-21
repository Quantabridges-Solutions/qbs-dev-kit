# QBS project constitution

> Governing principles for this repository. The agent must treat this file as authoritative when planning or implementing features. Update by consensus; do not bypass without an explicit team decision recorded in the spec or PR.

## Product and quality

- **User value first** — ship the smallest change that validates the scenario; avoid speculative features.
- **Consistency** — follow existing patterns in this repo (naming, layers, error shapes, UI patterns).
- **Observability** — meaningful logs and errors; no silent failures in API or jobs.

## Architecture (QBS stack)

- **Stack** — .NET API, EF Core + PostgreSQL, React (Vite) web, optional Expo mobile, Terraform on AWS, GitHub Actions.
- **Tenancy** — multi-tenant by default; every persisted entity that belongs to a customer must respect `OrganizationId` (or documented exception).
- **Auth** — OTP-first flows and JWT as defined in project rules; no password storage unless explicitly out of scope for a spike.

## Engineering standards

- **Migrations** — use `dotnet ef migrations add` / `update`; never hand-edit generated migration designer code to “fix” schema.
- **Security** — no secrets in source; validate input at boundaries; least-privilege IAM; review any new public surface area.
- **Tests** — add or update tests when behavior is non-trivial or regression-prone; do not add tests that only assert trivial wiring.

## Spec-driven workflow (this repo)

- **Order** — constitution (this file) → feature `spec.md` → clarify gaps → `plan.md` → `tasks.md` → implement.
- **Traceability** — each user story in `spec.md` maps to tasks in `tasks.md`; if something is out of scope, say so explicitly in the spec.

## Amendments

| Date | Change |
|------|--------|
| {TODAY} | Initial constitution from QBS Dev Kit template |
