# Cursor Setup

## Installation

Run the installer and select **Cursor only** or **Both**:

```bash
bash ~/source/qbs-dev-kit/install.sh
```

This installs skills to `~/.cursor/skills/` — available in every project you open in Cursor.

## What gets installed globally

```
~/.cursor/skills/
  scaffold-saas-project/    # New project scaffolding
  dotnet-services-feature/  # or dotnet-cqrs-feature/
  react-web-saas/
  react-native-expo/
  aws-saas-infra/
  saas-security-review/
```

## What gets installed per project

When you supply a project path during install (or run `/skill scaffold-saas-project`):

```
.cursor/rules/
  saas-global.mdc           # always active
  security.mdc              # always active
  dotnet-api.mdc            # active on src/backend/**/*.cs
  postgres-efcore.mdc       # active on src/backend/**/*.cs
  react-web.mdc             # active on src/frontend/**/*.{ts,tsx}
  react-native.mdc          # active on src/mobile/**/*.{ts,tsx}
  terraform-aws.mdc         # active on **/*.tf
  github-actions.mdc        # active on .github/workflows/*.yml
  docker.mdc                # active on docker-compose*.yml
```

## Using skills in Cursor

Skills are invoked automatically when you describe a task that matches, or you can reference them explicitly:

```
"Scaffold a new SaaS project called payroll-hub"
→ scaffold-saas-project skill activates

"Add an invoice entity with CRUD endpoints"
→ dotnet-services-feature skill activates

"Add a payments screen to the mobile app"
→ react-native-expo skill activates

"Security review this new endpoint"
→ saas-security-review skill activates

"Set up the AWS infrastructure"
→ aws-saas-infra skill activates
```

## Verifying rules are active

In any project with the rules installed, open a `.cs` file and ask Cursor:

> "What architecture pattern does this project use for the .NET API?"

Cursor should respond with the correct pattern from the `dotnet-api.mdc` rule.

## Adding rules to an existing project manually

```bash
# From your project root
mkdir -p .cursor/rules
cp ~/source/qbs-dev-kit/cursor/rules/*.mdc .cursor/rules/
```

Then remove any rules that don't apply (e.g. `react-native.mdc` for API-only projects).
