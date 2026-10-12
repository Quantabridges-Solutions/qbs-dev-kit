# Changelog

All notable QBS Dev Kit changes should be recorded here. Versions follow Semantic Versioning.

## 3.0.0 — 2026-10-12

### Added

- QBS specialist agents for planning, architecture, backend, frontend, testing, security, infrastructure, review and release readiness.
- Agent permission and tool-risk policies with explicit human-controlled production boundaries.
- Prompt-injection/untrusted-context policy and default-deny MCP governance.
- Critical agent eval scenarios for tenant isolation, prompt injection and production approval boundaries.
- Agent Plugins 1.0 portable manifest and MCP manifest.
- GitHub Copilot repository/path instructions and native custom-agent profiles.
- Machine-readable `qbs.project.yaml` project contract.
- Agent-run audit JSON schema.
- Agentic foundation overlay and generated-project governance validator.
- GitHub PR evidence template.
- CodeQL v4 and Dependency Review v5 workflow templates pinned to exact commits.
- Approval-gated database migration workflow.
- OpenTelemetry-first observability and agent audit telemetry guidance.
- Agentic delivery architecture guide.

### Changed

- AWS Lambda deployment now uses GitHub OIDC instead of long-lived AWS access keys.
- Application deployment no longer performs EF Core database migration.
- Secret scanning hook now fails closed.
- Project scaffolding skill applies the governed agentic foundation.
- `AGENTS.md`, security policy and README now document trust boundaries, verification loops and human production controls.
- Cursor and Claude plugin metadata bumped to v3.

### Security

- Production deploy, production database migration, destructive infrastructure changes, IAM escalation, production data mutation and production secret rotation are explicitly human-controlled.
- Portable MCP configuration enables no third-party servers by default.
