---
name: qbs-sdd-feature
description: "QBS spec-driven development for brownfield features: constitution, spec, clarify, plan, checklist, tasks, implement. Use specs/NNN-slug/ artifacts and docs/qbs-constitution.md."
when_to_use: Use when the user wants spec-driven development, SDD, structured specs before code, feature specs, implementation plans, task breakdowns, or mentions Spec Kit / speckit-style workflow for a QBS SaaS repo.
disable-model-invocation: true
---

# QBS spec-driven feature workflow

Use this skill when the user wants **structured delivery** (spec before code), **traceable artifacts**, or references **SDD / spec-kit style / speckit**.

## Preconditions

- Repo follows QBS layout (`src/backend`, `src/frontend`, optional `src/mobile`, `infra/terraform`).
- Prefer an existing `specs/NNN-slug/` folder; if missing, run `scripts/sdd/new-feature.sh <slug> [--title "..."]` from repo root (after scaffold copies kit files), or create `specs/NNN-slug/` manually from `templates/sdd/*-template.md`.

## Artifact map

| Phase | Primary output | Rules |
|-------|----------------|-------|
| Constitution | `docs/qbs-constitution.md` | Project-wide; skim or update before planning. |
| Specify | `specs/.../spec.md` | **What/why only** — no stack arguments. User stories + acceptance criteria + non-goals. |
| Clarify | `specs/.../spec.md` § Clarifications | Sequential questions; record Q/A in the table. |
| Plan | `specs/.../plan.md` | **How** — concrete paths, EF migrations via CLI, API contracts, tenancy. |
| Checklist | `specs/.../checklist.md` | Fill checkboxes; if failures, fix spec/plan first. |
| Tasks | `specs/.../tasks.md` | Ordered tasks, optional `[P]` for parallel-safe work, checkpoints per user story. |
| Implement | Code + tests | Follow `tasks.md`; use `dotnet-services-feature` / `dotnet-cqrs-feature` / `react-web-saas` / `react-native-expo` / `aws-saas-infra` where appropriate. |

## How to run a phase

The user may name a **single phase** or say **“full SDD”**. Unless they ask for everything at once, **execute one phase per user message** and stop with a short summary and suggested next prompt.

1. **Constitution** — If `docs/qbs-constitution.md` is missing, create it from the kit template `templates/sdd/constitution-template.md`. If present, only patch when the user asked to change principles.

2. **Specify** — Write or revise `spec.md`. Do not choose frameworks here. Include measurable acceptance criteria.

3. **Clarify** — Identify underspecified areas; ask targeted questions; append answers to Clarifications. Skip only if the user explicitly wants a spike.

4. **Plan** — Produce `plan.md` aligned with `.claude/rules` (multi-tenant, OTP/JWT, EF migrations, thin controllers). Reference real paths in this repo.

5. **Checklist** — Walk `checklist.md`; update spec/plan for any item that fails.

6. **Tasks** — Generate `tasks.md` from `plan.md` with dependency order; map each user story to a phase; add checkpoints.

7. **Implement** — Execute tasks in order; after each checkpoint, verify the related acceptance criteria from `spec.md`.

## Git

Recommend a feature branch (for example `cursor/<slug>-<token>`) when creating or editing `specs/NNN-slug/`. Commit spec/plan/tasks early for reviewability.

## Docs

Point the user to `docs/sdd-workflow.md` in the repo for the full human-readable guide.
