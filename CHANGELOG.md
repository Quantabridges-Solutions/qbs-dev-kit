# Changelog

All notable QBS Dev Kit changes should be recorded here. Versions follow Semantic Versioning.

## 3.1.0 — 2026-10-12

### Added

- Native GitHub Agentic Workflows (`gh-aw`) runtime with a pinned compiler and CI validation.
- `agent-ready` issue-to-draft-PR workflow with protected-file fallback, bounded shell commands and threat detection.
- Structured QBS Agent Task Issue Form that starts work as `agent-candidate` and requires explicit human promotion to `agent-ready`.
- Standard agentic-delivery label bootstrap for candidate/authorization, specialist routing, human review, previews and CI diagnostics.
- Independent read-only agentic PR reviewer.
- CI Doctor workflow that turns novel failed-build evidence into deduplicated diagnostic issues.
- Native per-run LLM evals and deterministic trajectory graders for implementation, review and CI-diagnostic agents.
- Explicit per-run/daily AI Credit budgets and separate threat-detection budgets.
- Weekly/manual agentic telemetry report for AIC spend, model routing, duration, evals and grader metrics.
- Disposable AWS `pr-N` preview environments created via a `preview` label and destroyed on unlabel/PR close.
- Preview Terraform support for `dev` and `pr-N` environments with RDS/Redis disabled by default.
- Extended agent-run schema for model/provider, AIC/token usage, evals, graders, safe outputs and trajectory metrics.
- Reusable CI Doctor template for generated QBS projects.

### Changed

- `qbs.project.yaml` schema moves to version 2 and declares the agentic runtime, telemetry and preview lifecycle.
- Agentic foundation overlay now installs runtime workflows, compiler/validator, telemetry, preview infrastructure, agent-task intake and label bootstrap.
- gh-aw compilation in routine CI is read-only: it validates/exports generated locks but does not receive workflow-rewrite authority; maintainers activate reviewed locks from an authenticated shell.
- Preview delivery is split into trust zones: trusted base-branch Terraform provisions infrastructure, PR code builds/tests without cloud credentials, and a separate publish job receives short-lived preview credentials only after artifacts are built.
- Fresh scaffold previews materialize an S3 backend declaration at runtime when no backend is configured and fail closed for non-S3 backends.
- CODEOWNERS now explicitly protects agentic workflows, issue intake, schemas, runtime templates and governance/bootstrap scripts.
- Dependabot ignores `github/gh-aw-actions/*` generated action pins; those pins are upgraded by updating gh-aw and recompiling.
- Plugin metadata bumped to v3.1.0.

### Security

- Agent-generated code remains draft-only and human-reviewed.
- Candidate issues are not executable until a human explicitly adds `agent-ready`.
- Agentic workflow writes go through gh-aw safe outputs and protected-file controls rather than direct model write permission.
- Routine CI cannot auto-approve gh-aw safe-update escalations and is not granted workflow-file write authority.
- Agent-generated PRs may use an optional GitHub App to mint short-lived credentials; long-lived AWS credentials remain prohibited.
- Preview environments reject fork PR execution, use trusted base-branch Terraform, and never expose AWS OIDC credentials to PR build/package scripts.
- Preview infrastructure uses a separate OIDC role and isolated Terraform workspace/state path.

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
