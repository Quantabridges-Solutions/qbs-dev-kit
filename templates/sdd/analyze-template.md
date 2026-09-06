# Analyze report: {FEATURE_TITLE}

**Feature:** `specs/{FEATURE_ID}/`  
**Date:** {TODAY}  
**Scope:** read-only consistency of `spec.md`, `plan.md`, and `tasks.md`.

## Summary

- Conflicts:
- Coverage gaps:
- Tenancy / auth gaps:
- Verdict: **Ready to implement** / **Return to specify** / **Return to plan** / **Return to tasks**

## Spec ↔ plan

| Spec item | Plan coverage | Notes |
|-----------|---------------|-------|
| | | |

## Plan ↔ tasks

| Plan item | Task IDs | Notes |
|-----------|----------|-------|
| | | |

## Orphans

- Requirements with no task:
- Tasks with no requirement:
- Plan choices that contradict the spec:

## QBS checks

- [ ] Every new persisted entity states `OrganizationId` (or an explicit global exception).
- [ ] Auth (OTP/JWT, who can call what) is specified or deferred.
- [ ] Migrations are EF CLI, not hand-written SQL.
- [ ] No secrets in plan examples.

## Remediations (do not apply in analyze phase unless asked)

1.
