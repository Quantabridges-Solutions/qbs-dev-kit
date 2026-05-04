# Claude Code Setup

## Installation

Run the installer and select **Claude Code only** or **Both**:

```bash
bash ~/source/qbs-dev-kit/install.sh
```

## What gets installed globally

```
~/.claude/
  CLAUDE.md                 # Loaded at the start of every Claude Code session
  rules/
    saas-global.md          # Always loaded
    security.md             # Always loaded
    dotnet-api.md           # Loaded when working in src/backend/
    postgres-efcore.md      # Loaded when working in src/backend/
    react-web.md            # Loaded when working in src/frontend/
    react-native.md         # Loaded when working in src/mobile/
    terraform-aws.md        # Loaded when working in .tf files
    github-actions.md       # Loaded when working in .github/workflows/
    docker.md               # Loaded when working in docker-compose files
  skills/
    scaffold-saas-project/
    dotnet-services-feature/
    react-web-saas/
    react-native-expo/
    aws-saas-infra/
    saas-security-review/
```

## What gets installed per project

When you supply a project path during install:

```
.claude/rules/              # Same rules as global, scoped to this project
CLAUDE.md                   # Project-level context — fill in project details
```

## The global CLAUDE.md

`~/.claude/CLAUDE.md` is loaded at the start of **every** Claude Code session on your machine. It contains:

- Your full stack overview (what technologies you use and where)
- 8 hard rules Claude always follows (OTP auth, no hand-written migrations, thin controllers, etc.)
- Your preferred .NET architecture pattern
- Bug fix output format

This means Claude knows your conventions from the very first message in any project.

## The project CLAUDE.md

When a project has a `CLAUDE.md` at its root, Claude loads it alongside the global one. Fill in the template with:

- Project name and one-line description
- Build and test commands specific to this project
- Migration commands with correct project names
- Key URLs (API, app)
- Any project-specific quirks or notes

## Using skills in Claude Code

Skills activate automatically or you can invoke them directly:

```bash
# In Claude Code terminal
/scaffold-saas-project
/dotnet-services-feature
/saas-security-review
```

Or just describe what you need in natural language — Claude will invoke the relevant skill.

## Path-scoped rules explained

Rules in `.claude/rules/` with a `paths:` frontmatter only load when Claude works with matching files:

```yaml
paths:
  - src/backend/**/*.cs
```

This saves context window space — the .NET rules don't load when you're editing Terraform files. Rules without `paths:` (saas-global, security) load at the start of every session.

## Verifying the setup

Start Claude Code in any project directory:

```bash
claude
```

Then ask:

> "What's the architecture pattern for the .NET API in this project?"

Claude should reference the `dotnet-api.md` rule and describe either Traditional Services or CQRS based on your choice at install time.
