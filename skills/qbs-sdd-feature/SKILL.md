---
name: qbs-sdd-feature
description: "QBS spec-driven development for brownfield features: constitution, spec, clarify, plan, checklist, tasks, analyze, implement, converge, and optional GitHub issues. Use when the user wants SDD, spec-kit style workflow, feature specs, plan before code, artifact consistency, or closing spec-to-code gaps. Artifacts live under specs/NNN-slug/ and docs/qbs-constitution.md."
license: CC-BY-ND-4.0
---

# QBS spec-driven feature workflow

Use when the user wants **structured delivery** (spec before code), **traceable artifacts**, or references **SDD / spec-kit / speckit**.

Unless they ask for everything at once, **execute one phase per user message**. Stop with a short summary and the suggested next prompt.

## Preconditions

- Repo follows QBS layout (`src/backend`, `src/frontend`, optional `src/mobile`, `infra/terraform`).
- Prefer an existing `specs/NNN-slug/` folder; if missing, run `scripts/sdd/new-feature.sh <slug> [--title "..."]` from repo root.

## Artifact map

| Phase | Output | Rules |
|-------|--------|-------|
| Constitution | `docs/qbs-constitution.md` | Project-wide; skim or update before planning. |
| Specify | `specs/.../spec.md` | What/why only — no stack arguments. |
| Clarify | `spec.md` § Clarifications | Sequential questions; record Q/A. |
| Plan | `plan.md` | How — paths, EF CLI migrations, API contracts, tenancy. Align with `.cursor/rules` or `.claude/rules`. |
| Checklist | `checklist.md` | Quality gate; fix spec/plan on failures. |
| Tasks | `tasks.md` | Ordered work, optional `[P]`, checkpoints per story. |
| Analyze | `analyze.md` | Read-only consistency report across spec/plan/tasks. **Before implement.** |
| Implement | Code + tests | Follow `tasks.md`; reuse feature skills. |
| Converge | `tasks.md` (append-only) | Code vs spec/plan/tasks; append missing work. Never delete tasks. |
| Tasks → issues | GitHub issues | Optional; after tasks, before or during implement. |

## Phase instructions

1. **Constitution** — Create from `templates/sdd/constitution-template.md` if missing. Patch only when asked.

2. **Specify** — Write `spec.md`. Measurable acceptance criteria. No framework debates.

3. **Clarify** — Targeted questions; append to Clarifications. Skip only for an explicit spike.

4. **Plan** — Concrete paths, OTP/JWT, `OrganizationId`, EF CLI. No new product requirements (send those back to spec).

5. **Checklist** — Walk `checklist.md`.

6. **Tasks** — Dependency order; map each user story; checkpoints.

7. **Analyze** — Produce `specs/.../analyze.md` from `templates/sdd/analyze-template.md`. Report conflicts, orphans (task with no requirement, requirement with no task), tenancy/auth gaps. **Do not edit spec/plan/tasks in this phase** unless the user asks you to apply remediations. If issues exist, recommend returning to specify/plan/tasks.

8. **Implement** — Execute tasks in order. After each checkpoint, verify acceptance criteria. Use `dotnet-services-feature` / `dotnet-cqrs-feature` / `react-web-saas` / `react-native-expo` / `qbs-test-feature` / `aws-saas-infra` as appropriate.

9. **Converge** — Diff the codebase against spec, plan, and tasks. If complete, say **Converged**. If gaps remain, append a `## Convergence` section to `tasks.md` (new tasks only; never rewrite history). Then suggest another implement pass.

10. **Tasks → issues** (optional) — `gh issue create` one issue per unchecked task (or per checkpoint group). Label `sdd` and `specs/NNN-slug`. Do not create duplicates; search existing issues first.

## Git

Recommend a feature branch (`feature/NNN-slug`). Commit spec/plan/tasks before large code drops.

## Docs

Point the user to `docs/sdd-workflow.md`.
