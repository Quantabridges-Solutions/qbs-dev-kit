## Requirement / spec

Link issue/spec and summarize the user-visible outcome.

## Change summary

- 

## Agent / automation disclosure

- Agent(s) used:
- Skills/tools used:
- Human decisions/approvals made:

## Verification evidence

- [ ] Build passes
- [ ] Unit tests pass
- [ ] Integration tests pass where applicable
- [ ] Tenant-isolation negative tests pass for tenant-owned data changes
- [ ] Browser/e2e verification completed for critical UI journeys
- [ ] CodeQL / security checks pass
- [ ] Dependency review passes
- [ ] Agentic governance/evals pass when agent rules/skills/policies changed

## Data / migration impact

Describe schema changes, migration execution plan, backwards compatibility and rollback. Production DB migration requires the protected environment approval path.

## Infrastructure / deployment impact

Describe Terraform/resource changes, replacement/destruction risk, IAM/network changes, cost-relevant additions and rollback.

## Observability

Describe new/changed logs, traces, metrics, alarms or dashboards and how this change can be diagnosed after release.

## Risk and rollback

- Risk: low / medium / high
- Rollback:

## Human approval boundary

List any action that must remain human-controlled (production deploy, production migration, destructive infrastructure, IAM escalation, production data write, secret rotation).
