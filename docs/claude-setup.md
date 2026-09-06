# Claude Code Setup

## Installation

```bash
bash /path/to/qbs-dev-kit/install.sh --provider claude --yes
```

Or pick **Claude Code only** / **Both** in the interactive installer.

The kit also ships `.claude-plugin/plugin.json` for Claude Code plugin install from this repo.

## What gets installed globally

```
~/.claude/
  CLAUDE.md
  rules/          # saas-global, security, stack rules, dotnet-api.md
  skills/         # same canonical skills as Cursor
```

## What gets installed per project

```
.claude/rules/
CLAUDE.md         # not overwritten if present
AGENTS.md
```

## Using skills

```
/scaffold-saas-project
/qbs-sdd-feature
/saas-security-review
```

Or describe the task; Claude loads matching skills (descriptions include WHEN). SDD is auto-invocable — do not set `disable-model-invocation` on kit skills.

## Path-scoped rules

Rules with `paths:` / globs load only for matching files. `saas-global` and `security` are always on.

## Verifying

```bash
claude
```

> What's the architecture pattern for the .NET API in this project?
