# QBS Agentic Runtime Smoke Test (First-Run)

This guide defines a **documentation-only** smoke test for the QBS issue-to-PR runtime. Its purpose is to validate the governed flow from a scoped issue to a single draft pull request, plus expected CI/reviewer/eval evidence, without changing executable delivery logic.

## Purpose and scope

- Validate the normal issue -> draft PR loop for the QBS agentic runtime.
- Validate that bounded output, draft-only PR behavior, and human approval boundaries are enforced.
- Keep change scope intentionally minimal: one documentation file in one PR.

This smoke test is not a feature rollout and not a production change process.

## Prerequisites

- Runtime source and lock workflows are already activated and in sync.
- The issue uses the QBS agent task structure with clear acceptance criteria and non-goals.
- A human maintainer explicitly authorizes execution by applying `agent-ready`.
- **For this first smoke test, do not use the `preview` label.**

## Expected flow (issue -> draft PR -> review evidence)

1. Create or confirm a bounded agent task issue for the smoke test.
2. Confirm labels and lane routing (for this task, documentation/testing lane behavior).
3. Human maintainer applies `agent-ready`.
4. The Issue-to-PR runtime executes and produces one **draft** PR.
5. Standard CI/reviewer/eval signals are attached to the draft PR/run.
6. Human reviewers inspect evidence and decide whether to continue, iterate, or close.

The implementation should remain narrow and should not widen into runtime, policy, infrastructure, or dependency refactors.

## Evidence to inspect

Inspect the generated draft PR and workflow artifacts for the following:

- Scope remained bounded to the expected documentation-only change.
- PR is draft and marked for human review.
- CI checks complete with expected pass/fail outcomes.
- Reviewer/eval output indicates no policy or boundary violations.
- No preview environment activity (because `preview` is intentionally not used).

## Out of scope and prohibited actions for this smoke test

The smoke test must not include any of the following:

- Production deployment.
- Production database migrations.
- IAM role/policy/privilege changes.
- Production data access or mutation.
- Changes under runtime/governance-protected surfaces (workflows, policies, dependencies, Terraform, plugin manifests).

## Cleanup and closure

After human review:

1. If evidence is acceptable, keep the PR history as baseline smoke-test evidence and close/merge per repository governance.
2. If evidence is not acceptable, close the draft PR and open a follow-up issue with specific corrective actions.
3. Record key findings (what worked, what failed, what to tighten) in the issue/PR conversation for future runtime runs.

Rollback is straightforward: close or revert the documentation-only PR. No runtime, infrastructure, or production side effects are expected from this smoke test.
