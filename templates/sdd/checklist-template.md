# Quality checklist: {FEATURE_TITLE}

**Artifacts:** `specs/{FEATURE_ID}/spec.md`, `plan.md`, `tasks.md`  
**Purpose:** “Unit tests for English” — catch gaps before implementation.

## Specification

- [ ] Every user story has clear acceptance signals.
- [ ] Non-goals block common scope-expansion paths.
- [ ] Tenancy (`OrganizationId` or exception) is explicit for new data.
- [ ] Auth paths (who can do what) are stated or deferred with reason.

## Plan

- [ ] Plan does not introduce new product requirements (send those back to spec).
- [ ] File paths / projects to touch are concrete enough to start coding.
- [ ] Migrations strategy is EF CLI, not hand-written SQL edits.
- [ ] Security section covers new endpoints and data exposure.

## Tasks

- [ ] Each acceptance criterion maps to at least one task or is marked deferred.
- [ ] Task order respects dependencies (models before services before UI, etc.).
- [ ] Parallel **[P]** tasks do not edit the same files.

## Post-implementation (fill after `/speckit.implement` or QBS implement step)

- [ ] All checkboxes in `spec.md` acceptance criteria verified.
- [ ] Regression checklist from PR / agent run completed.
