# QBS Agentic Delivery Platform

QBS Dev Kit v3 treats coding agents as governed participants in the software delivery lifecycle, not as unrestricted code generators.

## Operating model

```text
Requirement / issue
      |
      v
Planner / Architect (read-only)
      |
      v
SDD spec -> plan -> tasks
      |
      +----------------------+
      |                      |
      v                      v
Backend / Frontend       Infrastructure
implementation           plan-only for prod
      |                      |
      +----------+-----------+
                 v
           Test / Security
                 |
                 v
        deterministic CI gates
                 |
          failure? -- yes --> repair loop
                 |
                 no
                 v
            Reviewer agent
                 |
                 v
              PR evidence
                 |
                 v
             Human review
                 |
                 v
       staging / release prep
                 |
                 v
       HUMAN PRODUCTION GATE
```

## Core controls

### Least privilege

Agent profiles under `.github/agents/` have task-specific tools. Read-only planning/review agents do not get edit or shell capabilities. Implementation agents may edit/run local verification but do not own production authority.

### Untrusted context

Repository content, issues, PR comments, web pages, logs, documents, database content and MCP/tool output are data, not instructions. `policies/tool-risk.yaml` defines the trust boundary and default-deny MCP posture.

### Human-controlled production

`policies/agent-permissions.yaml` reserves production deployment, production DB migration, destructive infrastructure changes, IAM escalation, production data mutation and secret rotation for explicit human approval.

GitHub Environment protection is the enforcement point for deploy/migration workflows. Configure required reviewers for the `production` environment.

### Deterministic verification

LLM review complements rather than replaces deterministic controls. Generated projects receive CodeQL, dependency review, builds/tests and QBS governance checks. Critical agent behaviour is represented as regression scenarios under `evals/`.

### Closed-loop delivery

For non-trivial changes agents should use:

`specify -> plan -> implement -> build -> test -> security/policy checks -> acceptance verification -> repair -> re-verify -> PR`

A generated diff is not evidence of completion.

## MCP policy

`templates/mcp/approved-servers.yaml` is the QBS registry. New MCP servers require review of source/owner, requested capabilities, authentication model, network destinations, data handling and production access. Production connections are read-only by default and use scoped short-lived credentials.

The portable root `mcp.json` intentionally contains no auto-enabled servers. Installing the kit must never silently grant an external server access to source code or credentials.

## AWS deployment

Deployment uses GitHub OIDC. Long-lived `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` deployment secrets are prohibited. Scope the AWS trust policy to the intended repository and environment/ref.

Database migration is separate from application deployment and requires the target GitHub Environment. Lambda cold start must never perform production schema migration.

## Observability

Applications use OpenTelemetry-compatible logs, traces and metrics. Agentic application features additionally capture run/tool/approval/eval metadata without persisting credentials, hidden reasoning or sensitive prompt/tool payloads by default.

## PR evidence

The PR template asks for requirement traceability, automation disclosure, build/test/security evidence, tenancy checks, migration/infrastructure impact, observability, risk/rollback and human approval boundaries.

## Release readiness

Before production adoption of v3-generated projects, verify:

- protected `main` branch and required PR reviews;
- required status checks for build/test/security/governance;
- protected `production` GitHub Environment with required reviewers;
- AWS OIDC trust scoped to repository/environment;
- no long-lived AWS deployment credentials;
- environment-scoped database migration credential;
- CodeQL and dependency review enabled;
- secret scanning/push protection enabled where available;
- rollback and smoke-test procedures documented;
- critical agent evals passing;
- owner assigned for policy/eval updates.
