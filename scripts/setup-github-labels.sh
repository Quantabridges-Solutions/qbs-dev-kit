#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-}"

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required." >&2
  exit 1
fi

if [[ -n "$REPO" ]]; then
  REPO_ARGS=(--repo "$REPO")
else
  REPO_ARGS=()
  gh repo view >/dev/null 2>&1 || {
    echo "Run inside a GitHub repository or pass owner/repo as the first argument." >&2
    exit 1
  }
fi

create_label() {
  local name="$1" description="$2" color="$3"
  gh label create "$name" "${REPO_ARGS[@]}" --description "$description" --color "$color" --force
}

# Intake and authorization.
create_label "agent-candidate" "Candidate for agent-assisted delivery; not authorized to run yet" "D4C5F9"
create_label "agent-ready" "Human-reviewed and authorized for bounded issue-to-PR agent execution" "0E8A16"

# Specialist routing.
create_label "agent:backend" "Route agent work through QBS backend/API/data rules" "1D76DB"
create_label "agent:frontend" "Route agent work through QBS frontend/web rules" "5319E7"
create_label "agent:infra" "Route agent work through QBS infrastructure/Terraform rules" "B60205"
create_label "agent:test" "Route agent work through QBS testing/verification rules" "FBCA04"
create_label "agent:security" "Route agent work through QBS security review/hardening rules" "D93F0B"

# Agent output/review lifecycle.
create_label "agent-generated" "Content was produced by an agentic workflow" "C5DEF5"
create_label "needs-human-review" "Requires explicit human review before merge or release" "E99695"
create_label "preview" "Create/update disposable pr-N preview environment" "0052CC"
create_label "ci-failure" "CI failure requiring diagnosis/remediation" "B60205"

# Common automation/support labels used by templates.
create_label "dependencies" "Dependency update" "0366D6"
create_label "security" "Security-related change or finding" "D73A4A"
create_label "sdd" "Spec-driven development artifact or task" "7057FF"

echo "QBS agentic delivery labels are configured${REPO:+ for $REPO}."
