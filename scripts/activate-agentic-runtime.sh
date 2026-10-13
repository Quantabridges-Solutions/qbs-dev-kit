#!/usr/bin/env bash
set -euo pipefail

GH_AW_VERSION="v0.91.8"
COMMIT=false
APPROVE_REVIEWED=false

usage() {
  cat <<'EOF'
Usage: bash scripts/activate-agentic-runtime.sh [--approve-reviewed] [--commit]

Compiles and validates QBS GitHub Agentic Workflows from an authenticated
maintainer shell. This script never pushes or merges.

Options:
  --approve-reviewed  Pass gh-aw's --approve flag after the maintainer has
                      explicitly reviewed the safe-update escalation/diff.
  --commit            Stage source + generated lock files and create a local
                      commit after validation. Does not push.
  -h, --help          Show this help.

Normal first attempt should NOT use --approve-reviewed. If gh-aw reports a
restricted secret/action/trigger change, inspect it first, then rerun with the
flag only if that exact change is approved.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --approve-reviewed) APPROVE_REVIEWED=true; shift ;;
    --commit) COMMIT=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

command -v git >/dev/null 2>&1 || { echo "git is required" >&2; exit 1; }
command -v gh >/dev/null 2>&1 || { echo "GitHub CLI (gh) is required" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 1; }

git rev-parse --show-toplevel >/dev/null 2>&1 || {
  echo "Run this command inside a Git repository." >&2
  exit 1
}
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

for source in \
  .github/workflows/issue-to-pr.md \
  .github/workflows/pr-review.md \
  .github/workflows/ci-doctor.md; do
  [[ -f "$source" ]] || { echo "Missing agentic source workflow: $source" >&2; exit 1; }
done

# Enforce the exact compiler version used by QBS lock files. --force replaces an
# older/newer installed extension while --pin prevents accidental latest drift.
echo "Ensuring github/gh-aw $GH_AW_VERSION ..."
gh extension install github/gh-aw --force --pin "$GH_AW_VERSION"
gh aw version

compile_args=(compile --strict --yamllint)
if [[ "$APPROVE_REVIEWED" == true ]]; then
  compile_args+=(--approve)
  echo "WARNING: --approve-reviewed selected. This must correspond to a safe-update change you already inspected." >&2
fi

echo "Compiling QBS agentic workflow sources..."
if ! gh aw "${compile_args[@]}"; then
  cat >&2 <<'EOF'

Compilation did not complete.
If gh-aw reported a safe-update escalation (for example a new restricted
secret, action, redirect, or trigger), review the reported change and the
source diff. Only then rerun with --approve-reviewed if you explicitly approve
that exact change.
EOF
  exit 1
fi

echo "Validating compiled runtime..."
gh aw validate --strict
gh aw list --json | jq -e 'all(.[]; .compiled == "Yes")' >/dev/null

required=(
  .github/workflows/issue-to-pr.lock.yml
  .github/workflows/pr-review.lock.yml
  .github/workflows/ci-doctor.lock.yml
  .github/aw/actions-lock.json
)
for path in "${required[@]}"; do
  [[ -s "$path" ]] || { echo "Missing generated runtime artifact: $path" >&2; exit 1; }
done

# Generated workflows are security-sensitive. Keep the review surface explicit.
echo
echo "Generated files:"
git status --short -- .github/workflows/*.lock.yml .github/aw/actions-lock.json || true

echo
echo "Review before commit:"
echo "  git diff -- .github/workflows/*.lock.yml .github/aw/actions-lock.json"
echo "  git diff --stat -- .github/workflows/*.lock.yml .github/aw/actions-lock.json"

if [[ "$COMMIT" == true ]]; then
  git add \
    .github/workflows/issue-to-pr.md \
    .github/workflows/pr-review.md \
    .github/workflows/ci-doctor.md \
    .github/workflows/issue-to-pr.lock.yml \
    .github/workflows/pr-review.lock.yml \
    .github/workflows/ci-doctor.lock.yml \
    .github/aw/actions-lock.json

  git diff --cached --check

  if git diff --cached --quiet; then
    echo "No activation changes to commit. Runtime locks are already current."
  else
    git commit -m "chore: activate QBS agentic workflow locks"
    echo "Created local activation commit. Review it, then push through the normal PR process."
  fi
else
  echo
  echo "Runtime compilation is valid. No commit was created."
  echo "Rerun with --commit after reviewing the generated diff."
fi
