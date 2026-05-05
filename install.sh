#!/usr/bin/env bash
# QBS Standards Installer
# Installs personal skills and rules for Cursor and/or Claude Code
# Run from any directory: bash ~/source/quantabridges/qbs-standards/install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_SRC="$SCRIPT_DIR/cursor"
CLAUDE_SRC="$SCRIPT_DIR/claude"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  QBS Standards Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── AI provider choice ────────────────────────────────────────────────────────
echo "  Install skills for which AI provider?"
echo "    1) Cursor only"
echo "    2) Claude Code only"
echo "    3) Both Cursor + Claude Code"
echo ""
read -r -p "  Choose [1/2/3] (default: 3): " provider_choice
provider_choice="${provider_choice:-3}"

INSTALL_CURSOR=false
INSTALL_CLAUDE=false
case "$provider_choice" in
  1) INSTALL_CURSOR=true ;;
  2) INSTALL_CLAUDE=true ;;
  *) INSTALL_CURSOR=true; INSTALL_CLAUDE=true ;;
esac

# ── .NET architecture choice ──────────────────────────────────────────────────
echo ""
echo "  .NET API architecture pattern:"
echo "    1) Traditional Services  (recommended — Controllers → Services → DbContext)"
echo "    2) CQRS / MediatR        (Commands, Queries, Handlers)"
echo ""
read -r -p "  Choose [1/2] (default: 1): " dotnet_choice
dotnet_choice="${dotnet_choice:-1}"

case "$dotnet_choice" in
  2)
    DOTNET_SKILL="dotnet-cqrs-feature"
    CURSOR_DOTNET_RULE="dotnet-api-cqrs.mdc"
    CLAUDE_DOTNET_RULE="dotnet-api-cqrs.md"
    DOTNET_LABEL="CQRS / MediatR"
    ;;
  *)
    DOTNET_SKILL="dotnet-services-feature"
    CURSOR_DOTNET_RULE="dotnet-api-services.mdc"
    CLAUDE_DOTNET_RULE="dotnet-api-services.md"
    DOTNET_LABEL="Traditional Services"
    ;;
esac

COMMON_SKILLS=("scaffold-saas-project" "react-native-expo" "react-web-saas" "aws-saas-infra" "saas-security-review")
COMMON_RULES_BASE=("saas-global" "postgres-efcore" "react-web" "react-native" "terraform-aws" "github-actions" "docker" "security")

# ── Install Cursor skills ─────────────────────────────────────────────────────
if [ "$INSTALL_CURSOR" = "true" ]; then
  CURSOR_SKILLS_DEST="$HOME/.cursor/skills"
  echo ""
  echo "Installing Cursor skills to $CURSOR_SKILLS_DEST ..."
  mkdir -p "$CURSOR_SKILLS_DEST"

  for skill_name in "${COMMON_SKILLS[@]}"; do
    src="$CURSOR_SRC/skills/$skill_name"
    dest="$CURSOR_SKILLS_DEST/$skill_name"
    [ -d "$dest" ] && echo "  ↻ Updating:   $skill_name" || echo "  ✓ Installing: $skill_name"
    cp -r "${src%/}" "$CURSOR_SKILLS_DEST/"
  done

  dest="$CURSOR_SKILLS_DEST/$DOTNET_SKILL"
  [ -d "$dest" ] && echo "  ↻ Updating:   $DOTNET_SKILL  [$DOTNET_LABEL]" || echo "  ✓ Installing: $DOTNET_SKILL  [$DOTNET_LABEL]"
  cp -r "$CURSOR_SRC/skills/$DOTNET_SKILL" "$CURSOR_SKILLS_DEST/"
fi

# ── Install Claude Code skills ────────────────────────────────────────────────
if [ "$INSTALL_CLAUDE" = "true" ]; then
  CLAUDE_SKILLS_DEST="$HOME/.claude/skills"
  echo ""
  echo "Installing Claude Code skills to $CLAUDE_SKILLS_DEST ..."
  mkdir -p "$CLAUDE_SKILLS_DEST"

  for skill_name in "${COMMON_SKILLS[@]}"; do
    src="$CLAUDE_SRC/skills/$skill_name"
    dest="$CLAUDE_SKILLS_DEST/$skill_name"
    [ -d "$dest" ] && echo "  ↻ Updating:   $skill_name" || echo "  ✓ Installing: $skill_name"
    cp -r "${src%/}" "$CLAUDE_SKILLS_DEST/"
  done

  dest="$CLAUDE_SKILLS_DEST/$DOTNET_SKILL"
  [ -d "$dest" ] && echo "  ↻ Updating:   $DOTNET_SKILL  [$DOTNET_LABEL]" || echo "  ✓ Installing: $DOTNET_SKILL  [$DOTNET_LABEL]"
  cp -r "$CLAUDE_SRC/skills/$DOTNET_SKILL" "$CLAUDE_SKILLS_DEST/"

  # Install global CLAUDE.md
  CLAUDE_GLOBAL="$HOME/.claude/CLAUDE.md"
  [ -f "$CLAUDE_GLOBAL" ] && echo "  ↻ Updating:   ~/.claude/CLAUDE.md" || echo "  ✓ Installing: ~/.claude/CLAUDE.md"
  cp "$CLAUDE_SRC/CLAUDE.global.md" "$CLAUDE_GLOBAL"

  # Install global Claude rules
  CLAUDE_RULES_DEST="$HOME/.claude/rules"
  echo "  ✓ Installing: ~/.claude/rules/"
  mkdir -p "$CLAUDE_RULES_DEST"
  for rule_base in "${COMMON_RULES_BASE[@]}"; do
    cp "$CLAUDE_SRC/rules/${rule_base}.md" "$CLAUDE_RULES_DEST/"
  done
  cp "$CLAUDE_SRC/rules/$CLAUDE_DOTNET_RULE" "$CLAUDE_RULES_DEST/dotnet-api.md"
fi

# ── Copy rules to a specific project (optional) ───────────────────────────────
echo ""
echo "  Copy rules to a project directory?"
echo "  (Installs both .cursor/rules/ and .claude/rules/ + CLAUDE.md)"
echo ""
read -r -p "  Enter project path (or press Enter to skip): " project_path

# Expand ~ manually since read -r captures it as a literal character
project_path="${project_path/#\~/$HOME}"

if [ -n "$project_path" ] && [ ! -d "$project_path" ]; then
  echo "  ⚠ Path not found: $project_path  (skipping project install)"
  project_path=""
fi

if [ -n "$project_path" ] && [ -d "$project_path" ]; then
  if [ "$INSTALL_CURSOR" = "true" ]; then
    cursor_rules="$project_path/.cursor/rules"
    mkdir -p "$cursor_rules"
    for rule_base in "${COMMON_RULES_BASE[@]}"; do
      cp "$CURSOR_SRC/rules/${rule_base}.mdc" "$cursor_rules/"
    done
    cp "$CURSOR_SRC/rules/$CURSOR_DOTNET_RULE" "$cursor_rules/dotnet-api.mdc"
    echo "  ✓ Cursor rules → $cursor_rules/"
  fi

  if [ "$INSTALL_CLAUDE" = "true" ]; then
    claude_rules="$project_path/.claude/rules"
    mkdir -p "$claude_rules"
    for rule_base in "${COMMON_RULES_BASE[@]}"; do
      cp "$CLAUDE_SRC/rules/${rule_base}.md" "$claude_rules/"
    done
    cp "$CLAUDE_SRC/rules/$CLAUDE_DOTNET_RULE" "$claude_rules/dotnet-api.md"
    echo "  ✓ Claude rules → $claude_rules/"

    # Copy project CLAUDE.md if not already present
    if [ ! -f "$project_path/CLAUDE.md" ]; then
      cp "$CLAUDE_SRC/CLAUDE.project.md" "$project_path/CLAUDE.md"
      echo "  ✓ CLAUDE.md template → $project_path/CLAUDE.md  (fill in project details)"
    else
      echo "  ⚠ CLAUDE.md already exists — skipped (not overwritten)"
    fi
  fi
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Done!"
echo ""

if [ "$INSTALL_CURSOR" = "true" ]; then
  echo "  Cursor skills (~/.cursor/skills/):"
  for skill_name in "${COMMON_SKILLS[@]}"; do echo "    • $skill_name"; done
  echo "    • $DOTNET_SKILL  [$DOTNET_LABEL]"
  echo ""
fi

if [ "$INSTALL_CLAUDE" = "true" ]; then
  echo "  Claude Code skills (~/.claude/skills/):"
  for skill_name in "${COMMON_SKILLS[@]}"; do echo "    • $skill_name"; done
  echo "    • $DOTNET_SKILL  [$DOTNET_LABEL]"
  echo "  Claude global rules: ~/.claude/rules/"
  echo "  Claude global CLAUDE.md: ~/.claude/CLAUDE.md"
  echo ""
fi

echo "  Templates: $SCRIPT_DIR/templates/"
echo "  To re-run: bash $SCRIPT_DIR/install.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
