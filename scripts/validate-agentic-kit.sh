#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() { echo "ERROR: $*" >&2; exit 1; }
require_file() { [[ -f "$1" ]] || fail "Missing required file: $1"; }
require_pattern() { grep -Eq "$2" "$1" || fail "$1 missing required pattern: $2"; }
reject_pattern() { if grep -Eq "$2" "$1"; then fail "$1 contains forbidden pattern: $2"; fi; }

require_file policies/agent-permissions.yaml
require_file policies/tool-risk.yaml
require_file qbs.project.yaml
require_file templates/mcp/approved-servers.yaml
require_file evals/security/tenant-isolation.yaml
require_file evals/security/prompt-injection.yaml
require_file evals/governance/production-boundary.yaml
require_file .github/workflows/issue-to-pr.md
require_file .github/workflows/pr-review.md
require_file .github/workflows/ci-doctor.md
require_file .github/workflows/compile-agentic-workflows.yml
require_file .github/workflows/validate-agentic-workflows.yml
require_file .github/workflows/agentic-telemetry.yml
require_file templates/github-actions/preview-environment.yml
require_file templates/agentic-workflows/ci-doctor.md

for agent in \
  qbs-planner qbs-architect qbs-backend qbs-frontend qbs-test \
  qbs-security qbs-infrastructure qbs-reviewer qbs-release; do
  path=".github/agents/${agent}.agent.md"
  require_file "$path"
  require_pattern "$path" '^description:'
done

# Read-only agents must not be given edit/bash by accident.
for agent in qbs-planner qbs-architect qbs-reviewer; do
  path=".github/agents/${agent}.agent.md"
  reject_pattern "$path" 'tools:.*(edit|bash)'
done

# Production control and prompt-injection boundaries are critical invariants.
require_pattern policies/agent-permissions.yaml 'production_deploy'
require_pattern policies/agent-permissions.yaml 'human_approval_required'
require_pattern policies/tool-risk.yaml 'external_content_is_untrusted: true'
require_pattern policies/tool-risk.yaml 'default: deny'
require_pattern qbs.project.yaml 'production_human_control: true'
require_pattern qbs.project.yaml 'platform: github-agentic-workflows'
require_pattern qbs.project.yaml 'compiler_version: 0\.91\.8'
require_pattern qbs.project.yaml 'primary_cost_metric: ai_credits'

# Agentic runtime workflows must have bounded cost, measurable outcomes and safe writes.
for workflow in .github/workflows/issue-to-pr.md .github/workflows/pr-review.md .github/workflows/ci-doctor.md; do
  require_pattern "$workflow" '^max-ai-credits:'
  require_pattern "$workflow" '^graders:'
  require_pattern "$workflow" '^evals:'
  require_pattern "$workflow" 'threat-detection:'
done
require_pattern .github/workflows/issue-to-pr.md 'draft: true'
require_pattern .github/workflows/issue-to-pr.md 'protected-files: fallback-to-issue'
require_pattern .github/workflows/pr-review.md 'allowed-events: \[COMMENT\]'

# gh-aw source workflows must be compiled with a pinned CLI and validated in CI.
require_pattern .github/workflows/compile-agentic-workflows.yml 'github/gh-aw --pin v0\.91\.8'
require_pattern .github/workflows/validate-agentic-workflows.yml 'github/gh-aw --pin v0\.91\.8'
require_pattern .github/workflows/validate-agentic-workflows.yml 'gh aw validate --strict'

# Deployment templates may not rely on long-lived AWS access keys.
if [[ -f templates/github-actions/deploy-api-lambda.yml ]]; then
  reject_pattern templates/github-actions/deploy-api-lambda.yml 'AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY'
  require_pattern templates/github-actions/deploy-api-lambda.yml 'id-token: write'
  require_pattern templates/github-actions/deploy-api-lambda.yml 'role-to-assume'
fi

# Preview infrastructure must use OIDC and disposable pr-N environments; production is not a preview target.
reject_pattern templates/github-actions/preview-environment.yml 'AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY'
require_pattern templates/github-actions/preview-environment.yml 'AWS_PREVIEW_ROLE_ARN'
require_pattern templates/github-actions/preview-environment.yml 'PREVIEW_ENV: pr-'
require_pattern templates/github-actions/preview-environment.yml 'terraform destroy'
require_pattern templates/terraform/variables.tf '\^pr-\[0-9\]\+\$'

# Agent hooks protecting secrets must fail closed.
if [[ -f templates/hooks/hooks.json ]]; then
  python3 - <<'PY'
import json
from pathlib import Path
p = Path('templates/hooks/hooks.json')
data = json.loads(p.read_text())
secret_hooks = data.get('hooks', {}).get('beforeShellExecution', [])
if not secret_hooks:
    raise SystemExit('ERROR: no beforeShellExecution secret hook configured')
if not all(h.get('failClosed') is True for h in secret_hooks):
    raise SystemExit('ERROR: beforeShellExecution security hooks must failClosed=true')
PY
fi

echo "Agentic governance and runtime validation passed."
