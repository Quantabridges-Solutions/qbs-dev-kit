# Cursor Setup

## Installation

```bash
bash /path/to/qbs-dev-kit/install.sh --provider cursor --yes
```

Or pick **Cursor only** / **Both** in the interactive installer.

This copies canonical skills to `~/.cursor/skills/` and user rules to `~/.cursor/rules/`.

You can also install the repo as a [Cursor Plugin](https://cursor.com/docs/plugins) (`.cursor-plugin/plugin.json`) or Team Marketplace source instead of copying files.

## What gets installed globally

```
~/.cursor/skills/
  scaffold-saas-project/    # includes scripts/scaffold.sh
  dotnet-services-feature/  # or dotnet-cqrs-feature/
  react-web-saas/
  react-native-expo/
  aws-saas-infra/
  saas-security-review/
  qbs-sdd-feature/
  qbs-test-feature/
  qbs-code-review/
  qbs-observability/
  eas-release/
~/.cursor/rules/            # same .mdc files as a project
```

## What gets installed per project

When you pass `--project PATH` (or type a path in the interactive installer), or when scaffold runs:

```
.cursor/rules/              # glob-scoped .mdc files
.cursor/hooks.json          # secrets + tenant-filter hooks
.cursor/hooks/*.sh
AGENTS.md
```

## Using skills

Natural language is enough. Explicit attach still works:

```
@~/.cursor/skills/scaffold-saas-project/SKILL.md scaffold a new SaaS project called payroll-hub
```

## Verifying rules

Open a `.cs` file and ask: "What architecture pattern does this project use for the .NET API?"

## Adding rules to an existing project manually

```bash
bash /path/to/qbs-dev-kit/install.sh --provider cursor --project /path/to/app --yes
```
