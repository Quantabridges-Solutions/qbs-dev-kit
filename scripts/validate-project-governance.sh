#!/usr/bin/env bash
set -euo pipefail
TARGET="${1:-.}"
cd "$TARGET"

fail() { echo "ERROR: $*" >&2; exit 1; }
require() { [[ -f "$1" ]] || fail "Missing $1"; }

require AGENTS.md
require qbs.project.yaml
require aw.yml
require policies/agent-permissions.yaml
require policies/tool-risk.yaml
require .github/copilot-instructions.md
require .github/ISSUE_TEMPLATE/agent-task.yml
require .github/dependabot.yml
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
require scripts/setup-github-labels.sh
require scripts/activate-agentic-runtime.sh
require config/agentic/approved-mcp-servers.yaml

if grep -R -nE 'AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY' .github/workflows GITHUB_SECRETS.md 2>/dev/null; then
  fail "Long-lived AWS deployment credential guidance found"
fi

grep -q 'schema_version: 2' qbs.project.yaml || fail "qbs.project.yaml schema v2 required"
grep -q 'production_human_control: true' qbs.project.yaml || fail "production human control missing"
grep -q 'platform: github-agentic-workflows' qbs.project.yaml || fail "agentic runtime declaration missing"
grep -q 'external_content_is_untrusted: true' policies/tool-risk.yaml || fail "untrusted-context policy missing"
grep -q 'human_approval_required' policies/agent-permissions.yaml || fail "approval boundary missing"
grep -q '^manifest-version: "1"$' aw.yml || fail "gh-aw package manifest version missing"
grep -q '^min-version: v0.91.8$' aw.yml || fail "gh-aw package must require v0.91.8"
grep -q 'agent-candidate' .github/ISSUE_TEMPLATE/agent-task.yml || fail "agent task intake must start as candidate"
if grep -q 'labels:.*agent-ready' .github/ISSUE_TEMPLATE/agent-task.yml; then
  fail "agent task intake must not auto-authorize agent-ready"
fi
grep -q 'draft: true' .github/workflows/issue-to-pr.md || fail "agent-created PRs must remain draft"
grep -q 'protected-files: fallback-to-issue' .github/workflows/issue-to-pr.md || fail "protected-file fallback missing"
grep -q 'graders:' .github/workflows/issue-to-pr.md || fail "runtime graders missing"
grep -q 'evals:' .github/workflows/issue-to-pr.md || fail "runtime evals missing"
grep -q 'github/gh-aw-actions/\*' .github/dependabot.yml || fail "Dependabot must ignore gh-aw compiler-managed action pins"

grep -q 'GH_AW_VERSION="v0.91.8"' scripts/activate-agentic-runtime.sh || fail "activation helper must pin gh-aw v0.91.8"
grep -q 'GH_NO_EXTENSION_UPDATE_NOTIFIER=1' scripts/activate-agentic-runtime.sh || fail "activation helper must disable misleading extension update notices"
grep -q 'gh extension remove gh-aw' scripts/activate-agentic-runtime.sh || fail "activation helper must remove mismatched gh-aw before reinstall"
grep -q 'gh extension install github/gh-aw --pin "$GH_AW_VERSION"' scripts/activate-agentic-runtime.sh || fail "activation helper must install exact pinned gh-aw without --force"
if grep -q 'gh extension install github/gh-aw --force --pin' scripts/activate-agentic-runtime.sh; then
  fail "activation helper must not combine --force with --pin"
fi
grep -q 'Refusing to compile QBS lock workflows with a different compiler version' scripts/activate-agentic-runtime.sh || fail "activation helper must refuse compiler version drift"
if grep -Eq 'git push|gh pr merge|gh pr create' scripts/activate-agentic-runtime.sh; then
  fail "activation helper must never push, merge or open PRs"
fi

if grep -Eq 'gh aw compile[^\n]*--approve' .github/workflows/compile-agentic-workflows.yml; then
  fail "Routine CI must not auto-approve gh-aw safe-update escalations"
fi
if grep -q 'contents: write' .github/workflows/compile-agentic-workflows.yml; then
  fail "Routine gh-aw compile CI must remain read-only for repository contents"
fi

PREVIEW=.github/workflows/preview-environment.yml
grep -q 'AWS_PREVIEW_ROLE_ARN' "$PREVIEW" || fail "preview OIDC role missing"
grep -q 'head.repo.full_name == github.repository' "$PREVIEW" || fail "preview must reject fork execution"
grep -q 'Checkout trusted base-branch infrastructure' "$PREVIEW" || fail "preview Terraform must come from trusted base"
grep -q 'Checkout pull request without cloud credentials' "$PREVIEW" || fail "PR build must be isolated from cloud credentials"
grep -q '^  infra:' "$PREVIEW" || fail "preview infra trust zone missing"
grep -q '^  build:' "$PREVIEW" || fail "preview build trust zone missing"
grep -q '^  publish:' "$PREVIEW" || fail "preview publish trust zone missing"

if [[ -f .github/workflows/deploy-api-lambda.yml ]]; then
  grep -q 'id-token: write' .github/workflows/deploy-api-lambda.yml || fail "API deploy is not OIDC-enabled"
  grep -q 'role-to-assume' .github/workflows/deploy-api-lambda.yml || fail "API deploy missing role-to-assume"
fi

echo "Generated project governance and agentic runtime validation passed."
