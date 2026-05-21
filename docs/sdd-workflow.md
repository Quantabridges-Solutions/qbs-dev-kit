# Spec-driven development (SDD) with QBS Dev Kit

This workflow borrows structure from [GitHub Spec Kit](https://github.com/github/spec-kit): **intent and artifacts before code**, with phases that map cleanly to QBS SaaS conventions (multi-tenant .NET API, React web, optional Expo, Terraform).

Use it for **brownfield features** and any work where you want reviewable specs and traceability. It complements the **`scaffold-saas-project`** skill (greenfield) and feature skills (`dotnet-*-feature`, `react-web-saas`, etc.).

---

## When to use

- A non-trivial feature touching API, UI, or schema.
- You need PR-friendly documentation of **what** before **how**.
- Multiple contributors or handoffs between agent sessions.

Skip or shorten for pure chores (lint, version bumps) and spikes (label the spike in `spec.md` non-goals).

---

## Artifacts and layout

| Artifact | Path | Role |
|----------|------|------|
| Constitution | `docs/qbs-constitution.md` | Project-wide principles; read before plan/implement. |
| Feature folder | `specs/NNN-short-slug/` | One folder per initiative (number avoids collisions). |
| Spec | `specs/.../spec.md` | **What / why** — user stories, requirements, acceptance criteria. No stack debates here. |
| Plan | `specs/.../plan.md` | **How** — stack, files, migrations, API shapes, risks. |
| Tasks | `specs/.../tasks.md` | Ordered work, optional `[P]` parallel markers, checkpoints. |
| Checklist | `specs/.../checklist.md` | Quality gate on clarity and coverage. |

Templates ship in the kit at `templates/sdd/`. New scaffolds copy them into the repo under `templates/sdd/` plus `docs/sdd-workflow.md`.

---

## Bootstrap a new feature folder

From the repository root (after scaffold or manual copy of `scripts/sdd/` and `templates/sdd/`):

```bash
./scripts/sdd/new-feature.sh invoice-export --title "Invoice CSV export"
```

This creates `specs/00N-invoice-export/` with `spec.md`, `plan.md`, `tasks.md`, and `checklist.md` filled with placeholders.

---

## Phase order (recommended)

1. **Constitution** — Ensure `docs/qbs-constitution.md` exists and reflects your team rules. On first scaffold, the kit drops a template; refine once per product, not every feature.
2. **Specify** — Fill `spec.md`: goals, non-goals, user stories, acceptance criteria. Stay technology-agnostic.
3. **Clarify** — Resolve ambiguities; append to the Clarifications table in `spec.md`. Prefer this **before** `plan.md`.
4. **Plan** — Write `plan.md` with concrete paths under `src/backend`, `src/frontend`, `infra/terraform`, etc.
5. **Checklist** — Run through `checklist.md`; update spec/plan if gaps appear.
6. **Tasks** — Break `plan.md` into `tasks.md` with phases per user story and checkpoints.
7. **Implement** — Execute tasks in order; use existing QBS skills for vertical slices where applicable.
8. **Verify** — Acceptance criteria from `spec.md` plus `dotnet build` / tests / lint as in your repo.

---

## Agent skills (Cursor and Claude Code)

Install the kit with `install.sh` so **`qbs-sdd-feature`** is available in `~/.cursor/skills/` and/or `~/.claude/skills/`.

**Example (Cursor):**

```text
@~/.cursor/skills/qbs-sdd-feature/SKILL.md Run SDD specify phase for specs/003-invoice-export — user wants CSV export of invoices for accountants.
```

**Example (Claude Code):** same content; reference `~/.claude/skills/qbs-sdd-feature/SKILL.md` or describe the phase naturally.

The skill encodes the same phases so **Cursor and Claude stay aligned** — one workflow, two skill copies (format differences only).

---

## Git branching

Align with your team’s convention. A practical default:

- Branch per feature: `cursor/<slug>-<suffix>` or `feature/NNN-slug`.
- Commit spec/plan/tasks early so reviews can comment on intent before large code drops.

---

## Customization without forking the kit

Override order in your repo’s `docs/qbs-constitution.md`. Replace files under `templates/sdd/` in the **project** copy for org-specific wording. The installer always ships kit defaults; project copies win for that repository.

---

## See also

- [Skills reference](skills-reference.md) — `qbs-sdd-feature`
- [Getting started](getting-started.md) — scaffold and `@skill` usage
