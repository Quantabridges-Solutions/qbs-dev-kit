#!/usr/bin/env bash
# QBS Dev Kit installer — skills, rules, hooks for Cursor and/or Claude Code.
# Usage: bash install.sh [--provider cursor|claude|both] [--dotnet services|cqrs]
#                        [--project PATH] [--yes] [--dry-run] [--uninstall] [--help]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/kit-root.sh
source "$SCRIPT_DIR/scripts/lib/kit-root.sh"

KIT_ROOT="$SCRIPT_DIR"
VERSION="$(tr -d '[:space:]' < "$KIT_ROOT/VERSION" 2>/dev/null || echo "0.0.0")"
SKILLS_SRC="$KIT_ROOT/skills"
CURSOR_RULES_SRC="$KIT_ROOT/cursor/rules"
CLAUDE_SRC="$KIT_ROOT/claude"
CONFIG_DIR="${HOME}/.config/qbs-dev-kit"
KIT_ROOT_FILE="$CONFIG_DIR/kit-root"

COMMON_SKILLS=(
  scaffold-saas-project
  qbs-sdd-feature
  react-native-expo
  react-web-saas
  aws-saas-infra
  saas-security-review
  qbs-test-feature
  qbs-code-review
  qbs-observability
  eas-release
)
COMMON_RULES_BASE=(saas-global security postgres-efcore react-web react-native terraform-aws github-actions docker)

INSTALL_CURSOR=false
INSTALL_CLAUDE=false
DOTNET_SKILL="dotnet-services-feature"
CURSOR_DOTNET_RULE="dotnet-api-services.mdc"
CLAUDE_DOTNET_RULE="dotnet-api-services.md"
DOTNET_LABEL="Traditional Services"
PROJECT_PATH=""
NONINTERACTIVE=false
DRY_RUN=false
UNINSTALL=false
PROVIDER_SET=false
DOTNET_SET=false

usage() {
  cat <<EOF
QBS Dev Kit installer v${VERSION}

Usage: bash install.sh [options]

  --provider cursor|claude|both   Target AI provider (default: prompt, or both with --yes)
  --dotnet services|cqrs          .NET pattern (default: prompt, or services with --yes)
  --project PATH                  Copy rules/hooks/AGENTS.md into an existing project
  --yes, -y                       Non-interactive; use defaults
  --dry-run                       Print actions without writing files
  --uninstall                     Remove kit skills/rules written by this installer
  --help                          Show this help

Kit root is this checkout (${KIT_ROOT}). Re-run after git pull to update.
EOF
}

run() {
  if [ "$DRY_RUN" = true ]; then
    echo "  [dry-run] $*"
    return 0
  fi
  "$@"
}

copy_dir() {
  local src="$1" dest="$2"
  run mkdir -p "$(dirname "$dest")"
  run rm -rf "$dest"
  run cp -R "$src" "$dest"
}

copy_file() {
  local src="$1" dest="$2"
  run mkdir -p "$(dirname "$dest")"
  run cp "$src" "$dest"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --provider)
      PROVIDER_SET=true
      case "${2:-}" in
        1|cursor) INSTALL_CURSOR=true ;;
        2|claude) INSTALL_CLAUDE=true ;;
        3|both) INSTALL_CURSOR=true; INSTALL_CLAUDE=true ;;
        *) echo "Unknown --provider: ${2:-}" >&2; exit 1 ;;
      esac
      shift 2
      ;;
    --dotnet)
      DOTNET_SET=true
      case "${2:-}" in
        1|services)
          DOTNET_SKILL="dotnet-services-feature"
          CURSOR_DOTNET_RULE="dotnet-api-services.mdc"
          CLAUDE_DOTNET_RULE="dotnet-api-services.md"
          DOTNET_LABEL="Traditional Services"
          ;;
        2|cqrs)
          DOTNET_SKILL="dotnet-cqrs-feature"
          CURSOR_DOTNET_RULE="dotnet-api-cqrs.mdc"
          CLAUDE_DOTNET_RULE="dotnet-api-cqrs.md"
          DOTNET_LABEL="CQRS / MediatR"
          ;;
        *) echo "Unknown --dotnet: ${2:-}" >&2; exit 1 ;;
      esac
      shift 2
      ;;
    --project)
      PROJECT_PATH="${2:-}"
      shift 2
      ;;
    --yes|-y)
      NONINTERACTIVE=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --uninstall)
      UNINSTALL=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  QBS Dev Kit installer  v${VERSION}"
echo "  Kit: ${KIT_ROOT}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

uninstall_skills_from() {
  local dest="$1"
  [ -d "$dest" ] || return 0
  local name
  for name in "${COMMON_SKILLS[@]}" dotnet-services-feature dotnet-cqrs-feature; do
    if [ -d "$dest/$name" ]; then
      echo "  − $dest/$name"
      run rm -rf "$dest/$name"
    fi
  done
}

if [ "$UNINSTALL" = true ]; then
  echo "Removing QBS skills and recorded kit root..."
  uninstall_skills_from "$HOME/.cursor/skills"
  uninstall_skills_from "$HOME/.claude/skills"
  if [ -n "$PROJECT_PATH" ] && [ -d "$PROJECT_PATH" ]; then
    echo "  (project rules left in place — delete .cursor/rules and .claude/rules manually if needed)"
  fi
  if [ -f "$KIT_ROOT_FILE" ]; then
    run rm -f "$KIT_ROOT_FILE"
    echo "  − $KIT_ROOT_FILE"
  fi
  echo "Done."
  exit 0
fi

if [ "$PROVIDER_SET" = false ]; then
  if [ "$NONINTERACTIVE" = true ]; then
    INSTALL_CURSOR=true
    INSTALL_CLAUDE=true
  else
    echo "  Install skills for which AI provider?"
    echo "    1) Cursor only"
    echo "    2) Claude Code only"
    echo "    3) Both Cursor + Claude Code"
    echo ""
    read -r -p "  Choose [1/2/3] (default: 3): " provider_choice
    provider_choice="${provider_choice:-3}"
    case "$provider_choice" in
      1) INSTALL_CURSOR=true ;;
      2) INSTALL_CLAUDE=true ;;
      *) INSTALL_CURSOR=true; INSTALL_CLAUDE=true ;;
    esac
  fi
fi

if [ "$DOTNET_SET" = false ]; then
  if [ "$NONINTERACTIVE" = false ]; then
    echo ""
    echo "  .NET API architecture pattern:"
    echo "    1) Traditional Services  (recommended — Controllers → Services → DbContext)"
    echo "    2) CQRS / MediatR        (Commands, Queries, Handlers)"
    echo ""
    read -r -p "  Choose [1/2] (default: 1): " dotnet_choice
    dotnet_choice="${dotnet_choice:-1}"
    if [ "$dotnet_choice" = "2" ]; then
      DOTNET_SKILL="dotnet-cqrs-feature"
      CURSOR_DOTNET_RULE="dotnet-api-cqrs.mdc"
      CLAUDE_DOTNET_RULE="dotnet-api-cqrs.md"
      DOTNET_LABEL="CQRS / MediatR"
    fi
  fi
fi

install_skill() {
  local dest_root="$1" skill_name="$2"
  local src="$SKILLS_SRC/$skill_name"
  local dest="$dest_root/$skill_name"
  if [ ! -d "$src" ]; then
    echo "  ⚠ Missing skill source: $src" >&2
    return 1
  fi
  [ -d "$dest" ] && echo "  ↻ Updating:   $skill_name" || echo "  ✓ Installing: $skill_name"
  copy_dir "$src" "$dest"
}

if [ "$INSTALL_CURSOR" = true ]; then
  CURSOR_SKILLS_DEST="$HOME/.cursor/skills"
  echo ""
  echo "Installing Cursor skills to $CURSOR_SKILLS_DEST ..."
  run mkdir -p "$CURSOR_SKILLS_DEST"
  for skill_name in "${COMMON_SKILLS[@]}"; do
    install_skill "$CURSOR_SKILLS_DEST" "$skill_name"
  done
  dest="$CURSOR_SKILLS_DEST/$DOTNET_SKILL"
  [ -d "$dest" ] && echo "  ↻ Updating:   $DOTNET_SKILL  [$DOTNET_LABEL]" || echo "  ✓ Installing: $DOTNET_SKILL  [$DOTNET_LABEL]"
  copy_dir "$SKILLS_SRC/$DOTNET_SKILL" "$dest"
  # Opposite pattern: remove so the agent does not pick the wrong stack
  if [ "$DOTNET_SKILL" = "dotnet-services-feature" ]; then
    [ -d "$CURSOR_SKILLS_DEST/dotnet-cqrs-feature" ] && run rm -rf "$CURSOR_SKILLS_DEST/dotnet-cqrs-feature"
  else
    [ -d "$CURSOR_SKILLS_DEST/dotnet-services-feature" ] && run rm -rf "$CURSOR_SKILLS_DEST/dotnet-services-feature"
  fi

  CURSOR_RULES_DEST="$HOME/.cursor/rules"
  echo "  ✓ Installing: ~/.cursor/rules/"
  run mkdir -p "$CURSOR_RULES_DEST"
  for rule_base in "${COMMON_RULES_BASE[@]}"; do
    copy_file "$CURSOR_RULES_SRC/${rule_base}.mdc" "$CURSOR_RULES_DEST/${rule_base}.mdc"
  done
  copy_file "$CURSOR_RULES_SRC/$CURSOR_DOTNET_RULE" "$CURSOR_RULES_DEST/dotnet-api.mdc"
fi

if [ "$INSTALL_CLAUDE" = true ]; then
  CLAUDE_SKILLS_DEST="$HOME/.claude/skills"
  echo ""
  echo "Installing Claude Code skills to $CLAUDE_SKILLS_DEST ..."
  run mkdir -p "$CLAUDE_SKILLS_DEST"
  for skill_name in "${COMMON_SKILLS[@]}"; do
    install_skill "$CLAUDE_SKILLS_DEST" "$skill_name"
  done
  dest="$CLAUDE_SKILLS_DEST/$DOTNET_SKILL"
  [ -d "$dest" ] && echo "  ↻ Updating:   $DOTNET_SKILL  [$DOTNET_LABEL]" || echo "  ✓ Installing: $DOTNET_SKILL  [$DOTNET_LABEL]"
  copy_dir "$SKILLS_SRC/$DOTNET_SKILL" "$dest"
  if [ "$DOTNET_SKILL" = "dotnet-services-feature" ]; then
    [ -d "$CLAUDE_SKILLS_DEST/dotnet-cqrs-feature" ] && run rm -rf "$CLAUDE_SKILLS_DEST/dotnet-cqrs-feature"
  else
    [ -d "$CLAUDE_SKILLS_DEST/dotnet-services-feature" ] && run rm -rf "$CLAUDE_SKILLS_DEST/dotnet-services-feature"
  fi

  CLAUDE_GLOBAL="$HOME/.claude/CLAUDE.md"
  [ -f "$CLAUDE_GLOBAL" ] && echo "  ↻ Updating:   ~/.claude/CLAUDE.md" || echo "  ✓ Installing: ~/.claude/CLAUDE.md"
  copy_file "$CLAUDE_SRC/CLAUDE.global.md" "$CLAUDE_GLOBAL"

  CLAUDE_RULES_DEST="$HOME/.claude/rules"
  echo "  ✓ Installing: ~/.claude/rules/"
  run mkdir -p "$CLAUDE_RULES_DEST"
  for rule_base in "${COMMON_RULES_BASE[@]}"; do
    copy_file "$CLAUDE_SRC/rules/${rule_base}.md" "$CLAUDE_RULES_DEST/${rule_base}.md"
  done
  copy_file "$CLAUDE_SRC/rules/$CLAUDE_DOTNET_RULE" "$CLAUDE_RULES_DEST/dotnet-api.md"
fi

# Record kit location so scaffold.sh can find templates after skills are copied to ~
run mkdir -p "$CONFIG_DIR"
if [ "$DRY_RUN" = true ]; then
  echo "  [dry-run] echo $KIT_ROOT > $KIT_ROOT_FILE"
else
  printf '%s\n' "$KIT_ROOT" > "$KIT_ROOT_FILE"
  echo "  ✓ Kit root recorded: $KIT_ROOT_FILE"
fi

if [ "$NONINTERACTIVE" = false ] && [ -z "$PROJECT_PATH" ]; then
  echo ""
  echo "  Copy rules to a project directory?"
  echo "  (Installs .cursor/rules/, .claude/rules/, AGENTS.md, hooks)"
  echo ""
  read -r -p "  Enter project path (or press Enter to skip): " PROJECT_PATH
fi

PROJECT_PATH="${PROJECT_PATH/#\~/$HOME}"

if [ -n "$PROJECT_PATH" ] && [ ! -d "$PROJECT_PATH" ]; then
  echo "  ⚠ Path not found: $PROJECT_PATH  (skipping project install)"
  PROJECT_PATH=""
fi

install_project_rules() {
  local project_path="$1"
  if [ "$INSTALL_CURSOR" = true ]; then
    local cursor_rules="$project_path/.cursor/rules"
    run mkdir -p "$cursor_rules"
    for rule_base in "${COMMON_RULES_BASE[@]}"; do
      copy_file "$CURSOR_RULES_SRC/${rule_base}.mdc" "$cursor_rules/${rule_base}.mdc"
    done
    copy_file "$CURSOR_RULES_SRC/$CURSOR_DOTNET_RULE" "$cursor_rules/dotnet-api.mdc"
    echo "  ✓ Cursor rules → $cursor_rules/"

    run mkdir -p "$project_path/.cursor/hooks"
    copy_file "$KIT_ROOT/templates/hooks/hooks.json" "$project_path/.cursor/hooks.json"
    copy_file "$KIT_ROOT/templates/hooks/scan-secrets.sh" "$project_path/.cursor/hooks/scan-secrets.sh"
    copy_file "$KIT_ROOT/templates/hooks/check-tenant-filter.sh" "$project_path/.cursor/hooks/check-tenant-filter.sh"
    run chmod +x "$project_path/.cursor/hooks/scan-secrets.sh" "$project_path/.cursor/hooks/check-tenant-filter.sh"
    echo "  ✓ Cursor hooks → $project_path/.cursor/"
  fi

  if [ "$INSTALL_CLAUDE" = true ]; then
    local claude_rules="$project_path/.claude/rules"
    run mkdir -p "$claude_rules"
    for rule_base in "${COMMON_RULES_BASE[@]}"; do
      copy_file "$CLAUDE_SRC/rules/${rule_base}.md" "$claude_rules/${rule_base}.md"
    done
    copy_file "$CLAUDE_SRC/rules/$CLAUDE_DOTNET_RULE" "$claude_rules/dotnet-api.md"
    echo "  ✓ Claude rules → $claude_rules/"

    if [ ! -f "$project_path/CLAUDE.md" ]; then
      copy_file "$CLAUDE_SRC/CLAUDE.project.md" "$project_path/CLAUDE.md"
      echo "  ✓ CLAUDE.md template → $project_path/CLAUDE.md  (fill in project details)"
    else
      echo "  ⚠ CLAUDE.md already exists — skipped (not overwritten)"
    fi
  fi

  if [ ! -f "$project_path/AGENTS.md" ]; then
    copy_file "$KIT_ROOT/templates/agents/AGENTS.md" "$project_path/AGENTS.md"
    echo "  ✓ AGENTS.md → $project_path/AGENTS.md"
  else
    echo "  ⚠ AGENTS.md already exists — skipped (not overwritten)"
  fi
}

if [ -n "$PROJECT_PATH" ] && [ -d "$PROJECT_PATH" ]; then
  install_project_rules "$PROJECT_PATH"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Done!  v${VERSION}"
echo ""

if [ "$INSTALL_CURSOR" = true ]; then
  echo "  Cursor skills (~/.cursor/skills/):"
  for skill_name in "${COMMON_SKILLS[@]}"; do echo "    • $skill_name"; done
  echo "    • $DOTNET_SKILL  [$DOTNET_LABEL]"
  echo "  Cursor user rules: ~/.cursor/rules/"
  echo ""
fi

if [ "$INSTALL_CLAUDE" = true ]; then
  echo "  Claude Code skills (~/.claude/skills/):"
  for skill_name in "${COMMON_SKILLS[@]}"; do echo "    • $skill_name"; done
  echo "    • $DOTNET_SKILL  [$DOTNET_LABEL]"
  echo "  Claude global rules: ~/.claude/rules/"
  echo "  Claude global CLAUDE.md: ~/.claude/CLAUDE.md"
  echo ""
fi

echo "  Optional companions (do not vendor into this kit):"
echo "    npx skills add hashicorp/agent-skills --skill terraform-style-guide"
echo "    npx skills add vercel-labs/agent-skills --skill react-best-practices"
echo ""
echo "  Templates: $KIT_ROOT/templates/"
echo "  Re-run: bash $KIT_ROOT/install.sh"
echo "  Uninstall: bash $KIT_ROOT/install.sh --uninstall"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
