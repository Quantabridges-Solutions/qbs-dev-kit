#!/usr/bin/env bash
# Copy QBS kit files into the current (or --out) project directory.
# Language toolchains (dotnet new, pnpm, expo) are still run by the agent after this script.
#
# Usage:
#   scripts/scaffold.sh --name my-app [--components all|api|frontend|mobile|api+frontend|api+mobile]
#                       [--dotnet services|cqrs] [--region eu-west-1] [--out DIR]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=kit-root.sh
source "$SCRIPT_DIR/kit-root.sh"

if ! declare -F qbs_find_kit_root >/dev/null; then
  echo "Cannot load kit-root helper. Re-run install.sh from the qbs-dev-kit checkout." >&2
  exit 1
fi

KIT="$(qbs_find_kit_root "$SCRIPT_DIR" || true)"
if [[ -z "${KIT:-}" ]]; then
  echo "Cannot find QBS Dev Kit (templates/). Set QBS_KIT_ROOT to the kit checkout, or re-run install.sh." >&2
  exit 1
fi

PROJECT_NAME=""
COMPONENTS="all"
DOTNET_ARCH="services"
AWS_REGION="eu-west-1"
OUT_DIR="."

usage() {
  echo "Usage: $0 --name <project-name> [--components all] [--dotnet services|cqrs] [--region eu-west-1] [--out DIR]" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) PROJECT_NAME="${2:-}"; shift 2 ;;
    --components) COMPONENTS="${2:-all}"; shift 2 ;;
    --dotnet) DOTNET_ARCH="${2:-services}"; shift 2 ;;
    --region) AWS_REGION="${2:-eu-west-1}"; shift 2 ;;
    --out) OUT_DIR="${2:-.}"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$PROJECT_NAME" ]]; then
  echo "--name is required" >&2
  usage
  exit 1
fi

to_pascal() {
  echo "$1" | awk -F'[-_ ]' '{
    for (i = 1; i <= NF; i++) {
      w = $i
      if (length(w) > 0) printf "%s%s", toupper(substr(w,1,1)), substr(w,2)
    }
    print ""
  }'
}

PASCAL="$(to_pascal "$PROJECT_NAME")"
NEED_API=false
NEED_FRONTEND=false
NEED_MOBILE=false
case "$COMPONENTS" in
  all) NEED_API=true; NEED_FRONTEND=true; NEED_MOBILE=true ;;
  api) NEED_API=true ;;
  frontend) NEED_FRONTEND=true ;;
  mobile) NEED_MOBILE=true ;;
  api+frontend|frontend+api) NEED_API=true; NEED_FRONTEND=true ;;
  api+mobile|mobile+api) NEED_API=true; NEED_MOBILE=true ;;
  *) echo "Unknown --components: $COMPONENTS" >&2; exit 1 ;;
esac

mkdir -p "$OUT_DIR"
OUT_DIR="$(cd "$OUT_DIR" && pwd)"
cd "$OUT_DIR"

mkdir -p infra/terraform/scripts .github/workflows .cursor/rules .cursor/hooks .claude/rules
mkdir -p scripts specs templates/sdd scripts/sdd docs documents

[[ "$NEED_API" = true ]] && mkdir -p src/backend
[[ "$NEED_FRONTEND" = true ]] && mkdir -p src/frontend
[[ "$NEED_MOBILE" = true ]] && mkdir -p src/mobile

cp "$KIT/templates/gitignore/saas-full.gitignore" .gitignore
cp "$KIT/templates/cursorignore" .cursorignore
cp "$KIT/docs/sdd-workflow.md" docs/
cp "$KIT/templates/sdd/"*.md templates/sdd/
cp "$KIT/scripts/sdd/new-feature.sh" scripts/sdd/
chmod +x scripts/sdd/new-feature.sh
cp "$KIT/templates/sdd/constitution-template.md" docs/qbs-constitution.md
TODAY="$(date +%F)"
# constitution-template uses {TODAY}
if grep -q '{TODAY}' docs/qbs-constitution.md; then
  sed -i.bak "s/{TODAY}/$TODAY/g" docs/qbs-constitution.md && rm -f docs/qbs-constitution.md.bak
fi

cp "$KIT/templates/agents/AGENTS.md" AGENTS.md
if [[ ! -f CLAUDE.md ]]; then
  sed "s/{Project Name}/$PASCAL/g; s/{ProjectName}/$PASCAL/g; s/{project_name}/$PROJECT_NAME/g" \
    "$KIT/claude/CLAUDE.project.md" > CLAUDE.md
fi

# Cursor + Claude rules
KIT_CR="$KIT/cursor/rules"
KIT_CL="$KIT/claude/rules"
cp "$KIT_CR/saas-global.mdc" "$KIT_CR/security.mdc" "$KIT_CR/github-actions.mdc" "$KIT_CR/docker.mdc" .cursor/rules/
cp "$KIT_CL/saas-global.md" "$KIT_CL/security.md" "$KIT_CL/github-actions.md" "$KIT_CL/docker.md" .claude/rules/
cp "$KIT_CR/terraform-aws.mdc" .cursor/rules/
cp "$KIT_CL/terraform-aws.md" .claude/rules/

if [[ "$NEED_API" = true ]]; then
  cp "$KIT_CR/postgres-efcore.mdc" .cursor/rules/
  cp "$KIT_CL/postgres-efcore.md" .claude/rules/
  if [[ "$DOTNET_ARCH" = "cqrs" ]]; then
    cp "$KIT_CR/dotnet-api-cqrs.mdc" .cursor/rules/dotnet-api.mdc
    cp "$KIT_CL/dotnet-api-cqrs.md" .claude/rules/dotnet-api.md
  else
    cp "$KIT_CR/dotnet-api-services.mdc" .cursor/rules/dotnet-api.mdc
    cp "$KIT_CL/dotnet-api-services.md" .claude/rules/dotnet-api.md
  fi
fi
[[ "$NEED_FRONTEND" = true ]] && cp "$KIT_CR/react-web.mdc" .cursor/rules/ && cp "$KIT_CL/react-web.md" .claude/rules/
[[ "$NEED_MOBILE" = true ]] && cp "$KIT_CR/react-native.mdc" .cursor/rules/ && cp "$KIT_CL/react-native.md" .claude/rules/

# Hooks
cp "$KIT/templates/hooks/hooks.json" .cursor/hooks.json
cp "$KIT/templates/hooks/scan-secrets.sh" .cursor/hooks/
cp "$KIT/templates/hooks/check-tenant-filter.sh" .cursor/hooks/
chmod +x .cursor/hooks/*.sh

cat > .env.example <<EOF
DB_PASSWORD=change-me
JWT_KEY=generate-with-openssl-rand-base64-32
RESEND_API_KEY=re_xxx
AWS_REGION=${AWS_REGION}
EOF

if [[ "$NEED_API" = true ]]; then
  cp "$KIT/templates/docker/Dockerfile.api" src/backend/Dockerfile
fi
if [[ "$NEED_FRONTEND" = true ]]; then
  cp "$KIT/templates/docker/Dockerfile.frontend" src/frontend/Dockerfile
  cp "$KIT/templates/docker/nginx.conf" src/frontend/nginx.conf
fi

sed "s/{project}/$PROJECT_NAME/g; s/{PROJECT}/$(printf '%s' "$PROJECT_NAME" | tr '[:lower:]' '[:upper:]')/g; s/{Project}/$PASCAL/g" \
  "$KIT/templates/docker/docker-compose.yml" > docker-compose.yml

TF_SRC="$KIT/templates/terraform"
cp "$TF_SRC"/*.tf infra/terraform/
cp "$TF_SRC"/*.example infra/terraform/
if grep -q 'variable "project_name"' infra/terraform/variables.tf; then
  :
fi
# Default project_name in tfvars example
sed -i.bak "s/project_name = \"myproject\"/project_name = \"$PROJECT_NAME\"/" infra/terraform/terraform.tfvars.example && rm -f infra/terraform/terraform.tfvars.example.bak
sed -i.bak "s/aws_region   = \"eu-west-1\"/aws_region   = \"$AWS_REGION\"/" infra/terraform/terraform.tfvars.example && rm -f infra/terraform/terraform.tfvars.example.bak

GH_SRC="$KIT/templates/github-actions"
[[ "$NEED_API" = true ]] && cp "$GH_SRC/deploy-api-lambda.yml" "$GH_SRC/dotnet-test.yml" .github/workflows/
[[ "$NEED_FRONTEND" = true ]] && cp "$GH_SRC/deploy-frontend-s3.yml" "$GH_SRC/frontend-test.yml" .github/workflows/
[[ "$NEED_MOBILE" = true ]] && cp "$GH_SRC/mobile-ios-build.yml" "$GH_SRC/mobile-android-build.yml" .github/workflows/
cp "$GH_SRC/terraform-plan.yml" .github/workflows/

# Substitute {project} in workflows
for f in .github/workflows/*.yml; do
  sed -i.bak "s/{project}/$PROJECT_NAME/g; s/{Project}/$PASCAL/g; s/{PascalName}/$PASCAL/g" "$f" && rm -f "${f}.bak"
done

cat > GITHUB_SECRETS.md <<EOF
# Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| \`AWS_ACCESS_KEY_ID\` | IAM deploy user key |
| \`AWS_SECRET_ACCESS_KEY\` | IAM deploy user secret |
| \`AWS_REGION\` | e.g. \`${AWS_REGION}\` |
| \`DB_PASSWORD\` | RDS database password |
| \`JWT_KEY\` | JWT signing secret (min 32 chars) |
| \`RESEND_API_KEY\` | Resend email API key |
| \`EXPO_TOKEN\` | EAS build token (mobile only) |
EOF

cat > README.md <<EOF
# ${PASCAL}

> SaaS platform — API (AWS Lambda) · Web (CloudFront/S3) · Mobile (Expo)

## Quick start
\`\`\`bash
cp .env.example .env   # fill in DB_PASSWORD, JWT_KEY, RESEND_API_KEY
docker compose up
\`\`\`

## Services (local)
| Service | URL |
|---------|-----|
| API | http://localhost:5075 |
| API docs (Scalar) | http://localhost:5075/scalar |
| Health check | http://localhost:5075/health |
| Frontend | http://localhost:3000 |
| Email capture | http://localhost:5050 |

## Stack
- **Backend** — .NET 8, EF Core, PostgreSQL, Redis, JWT · AWS Lambda
- **Frontend** — React 19, Vite, TypeScript, Tailwind CSS · S3 + CloudFront
- **Mobile** — React Native, Expo · EAS
- **Infra** — Terraform (AWS)

## Spec-driven development
\`./scripts/sdd/new-feature.sh <slug>\` then use the \`qbs-sdd-feature\` skill.

## Deployment
Push to \`main\` → GitHub Actions. See \`GITHUB_SECRETS.md\`.
EOF

echo "Scaffold files copied into $OUT_DIR"
echo "KIT=$KIT"
echo "PROJECT_NAME=$PROJECT_NAME"
echo "PASCAL=$PASCAL"
echo "NEED_API=$NEED_API NEED_FRONTEND=$NEED_FRONTEND NEED_MOBILE=$NEED_MOBILE"
echo "DOTNET_ARCH=$DOTNET_ARCH AWS_REGION=$AWS_REGION"
echo "Next: run language toolchains (dotnet new / pnpm create vite / create-expo-app) as in the skill."
