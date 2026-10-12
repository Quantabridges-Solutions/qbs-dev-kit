#!/usr/bin/env bash
set -euo pipefail
TARGET="${1:-.}"
cd "$TARGET"

fail() { echo "ERROR: $*" >&2; exit 1; }
require() { [[ -f "$1" ]] || fail "Missing $1"; }

require AGENTS.md
require qbs.project.yaml
require policies/agent-permissions.yaml
require policies/tool-risk.yaml
require .github/copilot-instructions.md
require .github/agents/qbs-planner.agent.md
require .github/agents/qbs-security.agent.md
require .github/agents/qbs-release.agent.md
require .github/workflows/dependency-review.yml
require .github/workflows/codeql.yml
require .github/workflows/database-migrate.yml
require .github/workflows/issue-to-pr.md
require .github/workflows/pr-review.md
require .github/workflows/ci-doctor.md
require .github/workflows/compile-agentic-workflows.yml
require .github/workflows/validate-agentic-workflows.yml
require .github/workflows/agentic-telemetry.yml
require .github/workflows/preview-environment.yml
require config/agentic/approved-mcp-servers.yaml

if grep -R -nE 'AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY' .github/workflows GITHUB_SECRETS.md 2>/dev/null; then
  fail "Long-lived AWS deployment credential guidance found"
fi

grep -q 'schema_version: 2' qbs.project.yaml || fail "qbs.project.yaml schema v2 required"
grep -q 'production_human_control: true' qbs.project.yaml || fail "production human control missing"
grep -q 'platform: github-agentic-workflows' qbs.project.yaml || fail "agentic runtime declaration missing"
grep -q 'external_content_is_untrusted: true' policies/tool-risk.yaml || fail "untrusted-context policy missing"
grep -q 'human_approval_required' policies/agent-permissions.yaml || fail "approval boundary missing"
grep -q 'draft: true' .github/workflows/issue-to-pr.md || fail "agent-created PRs must remain draft"
grep -q 'protected-files: fallback-to-issue' .github/workflows/issue-to-pr.md || fail "protected-file fallback missing"
grep -q 'graders:' .github/workflows/issue-to-pr.md || fail "runtime graders missing"
grep -q 'evals:' .github/workflows/issue-to-pr.md || fail "runtime evals missing"
grep -q 'AWS_PREVIEW_ROLE_ARN' .github/workflows/preview-environment.yml || fail "preview OIDC role missing"

if [[ -f .github/workflows/deploy-api-lambda.yml ]]; then
  grep -q 'id-token: write' .github/workflows/deploy-api-lambda.yml || fail "API deploy is not OIDC-enabled"
  grep -q 'role-to-assume' .github/workflows/deploy-api-lambda.yml || fail "API deploy missing role-to-assume"
fi

echo "Generated project governance and agentic runtime validation passed."
