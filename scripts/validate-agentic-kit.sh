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

# Deployment templates may not rely on long-lived AWS access keys.
if [[ -f templates/github-actions/deploy-api-lambda.yml ]]; then
  reject_pattern templates/github-actions/deploy-api-lambda.yml 'AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY'
  require_pattern templates/github-actions/deploy-api-lambda.yml 'id-token: write'
  require_pattern templates/github-actions/deploy-api-lambda.yml 'role-to-assume'
fi

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

echo "Agentic governance validation passed."
