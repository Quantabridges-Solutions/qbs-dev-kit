# Implementation tasks: {FEATURE_TITLE}

**Plan:** `specs/{FEATURE_ID}/plan.md`  
**Status:** Draft  
**Last updated:** {TODAY}

## Conventions

- **Order** — follow phases; within a phase, respect dependencies.
- **[P]** — can run in parallel with other **[P]** tasks in the same phase when no shared files conflict.
- **Checkpoint** — after each user-story phase, stop and verify acceptance criteria before continuing.

## Phase 1 — Setup

- [ ] **T1** Create branch `cursor/{FEATURE_SLUG}-…` or team convention; ensure `specs/{FEATURE_ID}/` tracked.
- [ ] **T2** [P] Confirm local prerequisites (Docker, .NET SDK, pnpm) per `README.md`.

## Phase 2 — User story US-1

**Maps to:** spec § User stories — US-1

- [ ] **T3** …
- [ ] **T4** [P] …

**Checkpoint:** …

## Phase 3 — User story US-2

**Maps to:** US-2

- [ ] **T5** …

**Checkpoint:** …

## Phase 4 — Verification

- [ ] **T** Run `dotnet build` / `dotnet test` for backend changes.
- [ ] **T** Run web/mobile lint or tests as applicable.
- [ ] **T** Manual acceptance against `spec.md` acceptance criteria.

## Optional — GitHub issues

- [ ] Run `gh issue create` per task or batch (if using issue-driven execution).
