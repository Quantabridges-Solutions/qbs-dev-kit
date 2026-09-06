#!/usr/bin/env bash
# Validate Agent Skills frontmatter (agentskills.io): name matches folder, required fields.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="${ROOT}/skills"
errors=0

if [[ ! -d "$SKILLS_DIR" ]]; then
  echo "Missing $SKILLS_DIR" >&2
  exit 1
fi

while IFS= read -r skill_md; do
  dir="$(dirname "$skill_md")"
  folder="$(basename "$dir")"
  name="$(awk 'BEGIN{f=0} /^---$/{f++; next} f==1 && /^name:/{sub(/^name:[[:space:]]*/,""); gsub(/"/,""); print; exit}' "$skill_md")"
  desc="$(awk 'BEGIN{f=0} /^---$/{f++; next} f==1 && /^description:/{print; exit}' "$skill_md")"
  skill_errors=0

  if [[ -z "$name" ]]; then
    echo "FAIL $folder: missing name in frontmatter"
    skill_errors=$((skill_errors + 1))
  elif [[ "$name" != "$folder" ]]; then
    echo "FAIL $folder: name '$name' does not match folder"
    skill_errors=$((skill_errors + 1))
  fi

  if [[ -z "$desc" ]]; then
    echo "FAIL $folder: missing description"
    skill_errors=$((skill_errors + 1))
  fi

  if [[ ! "$folder" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "FAIL $folder: folder name is not kebab-case"
    skill_errors=$((skill_errors + 1))
  fi

  if grep -qE '^when_to_use:' "$skill_md"; then
    echo "FAIL $folder: when_to_use is not in the Agent Skills spec — put WHEN in description"
    skill_errors=$((skill_errors + 1))
  fi

  if [[ "$skill_errors" -eq 0 ]]; then
    echo "OK   $folder"
  else
    errors=$((errors + skill_errors))
  fi
done < <(find "$SKILLS_DIR" -name SKILL.md | sort)

if [[ "$errors" -gt 0 ]]; then
  echo ""
  echo "$errors skill validation error(s)"
  exit 1
fi

echo ""
echo "All skills valid."
