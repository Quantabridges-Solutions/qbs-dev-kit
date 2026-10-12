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
require config/agentic/approved-mcp-servers.yaml

if grep -R -nE 'AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY' .github/workflows GITHUB_SECRETS.md 2>/dev/null; then
  fail "Long-lived AWS deployment credential guidance found"
fi

grep -q 'production_human_control: true' qbs.project.yaml || fail "production human control missing"
grep -q 'external_content_is_untrusted: true' policies/tool-risk.yaml || fail "untrusted-context policy missing"
grep -q 'human_approval_required' policies/agent-permissions.yaml || fail "approval boundary missing"

if [[ -f .github/workflows/deploy-api-lambda.yml ]]; then
  grep -q 'id-token: write' .github/workflows/deploy-api-lambda.yml || fail "API deploy is not OIDC-enabled"
  grep -q 'role-to-assume' .github/workflows/deploy-api-lambda.yml || fail "API deploy missing role-to-assume"
fi

echo "Generated project governance validation passed."
