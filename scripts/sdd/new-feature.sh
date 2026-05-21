#!/usr/bin/env bash
# Create specs/NNN-slug/ with QBS SDD templates from this repository.
# Usage: scripts/sdd/new-feature.sh <feature-slug> [--title "My Feature Title"]
# Run from repository root, or any path (script locates root via git).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Repo root = parent of scripts/ (this file lives in scripts/sdd/)
REPO_CANDIDATE="$(cd "${SCRIPT_DIR}/../.." && pwd)"
if git -C "$REPO_CANDIDATE" rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT="$(git -C "$REPO_CANDIDATE" rev-parse --show-toplevel)"
else
  REPO_ROOT="$REPO_CANDIDATE"
fi

SLUG_RAW="${1:-}"
if [[ -z "$SLUG_RAW" ]]; then
  echo "Usage: $0 <feature-slug> [--title \"Feature Title\"]" >&2
  exit 1
fi
shift || true

TITLE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)
      TITLE="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-'
}

SLUG="$(slugify "$SLUG_RAW")"
if [[ -z "$SLUG" ]]; then
  echo "Invalid slug after normalization: '$SLUG_RAW'" >&2
  exit 1
fi

TEMPLATE_SRC="${REPO_ROOT}/templates/sdd"
if [[ ! -d "$TEMPLATE_SRC" ]]; then
  echo "Missing template directory: $TEMPLATE_SRC" >&2
  echo "Copy templates/sdd from QBS Dev Kit or set REPO_ROOT correctly." >&2
  exit 1
fi

SPECS_DIR="${REPO_ROOT}/specs"
mkdir -p "$SPECS_DIR"

max_num=0
if compgen -G "${SPECS_DIR}/[0-9][0-9][0-9]-*" >/dev/null; then
  for d in "${SPECS_DIR}/"???-*; do
    [[ -d "$d" ]] || continue
    base="$(basename "$d")"
    num="${base%%-*}"
    if [[ "$num" =~ ^[0-9]{3}$ ]]; then
      n=$((10#$num))
      (( n > max_num )) && max_num=$n
    fi
  done
fi

NEXT=$((max_num + 1))
FEATURE_ID="$(printf '%03d' "$NEXT")-${SLUG}"
DEST="${SPECS_DIR}/${FEATURE_ID}"
if [[ -e "$DEST" ]]; then
  echo "Already exists: $DEST" >&2
  exit 1
fi

mkdir -p "$DEST"

TODAY="$(date +%F)"
FEATURE_TITLE="$TITLE"
[[ -n "$FEATURE_TITLE" ]] || FEATURE_TITLE="$SLUG"

substitute() {
  sed \
    -e "s/{FEATURE_ID}/$FEATURE_ID/g" \
    -e "s/{FEATURE_SLUG}/$SLUG/g" \
    -e "s/{FEATURE_TITLE}/$FEATURE_TITLE/g" \
    -e "s/{TODAY}/$TODAY/g"
}

cp "${TEMPLATE_SRC}/spec-template.md" "${DEST}/spec.md"
cp "${TEMPLATE_SRC}/plan-template.md" "${DEST}/plan.md"
cp "${TEMPLATE_SRC}/tasks-template.md" "${DEST}/tasks.md"
cp "${TEMPLATE_SRC}/checklist-template.md" "${DEST}/checklist.md"

for f in spec plan tasks checklist; do
  tmp="${DEST}/${f}.md.tmp"
  mv "${DEST}/${f}.md" "$tmp"
  substitute <"$tmp" >"${DEST}/${f}.md"
  rm -f "$tmp"
done

echo "Created ${DEST}/"
echo "  spec.md  plan.md  tasks.md  checklist.md"
