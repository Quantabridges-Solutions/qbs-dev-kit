#!/usr/bin/env bash
# beforeShellExecution: block committing secrets or hand-writing EF migrations.
set -euo pipefail

input="$(cat)"
command="$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("command",""))' 2>/dev/null || printf '%s' "$input")"

deny() {
  python3 -c 'import json,sys; print(json.dumps({"permission":"deny","user_message":sys.argv[1],"agent_message":sys.argv[1]}))' "$1"
  exit 0
}

allow() {
  printf '%s\n' '{"permission":"allow"}'
  exit 0
}

# git add/commit of env, tfvars, keys
if printf '%s' "$command" | grep -Eqi '(git[[:space:]]+(add|commit|commit[[:space:]].*--))'; then
  if printf '%s' "$command" | grep -Eqi '(^|[[:space:]])(\.env|.*\.env[[:space:]]|\.env\.|terraform\.tfvars|[[:space:]]id_rsa|[[:space:]].*\.pem)'; then
    deny "Refusing to stage/commit secret-like files (.env, terraform.tfvars, keys). Use .env.example and gitignored tfvars."
  fi
fi

# Hand-written EF migration files — agents must use dotnet ef
if printf '%s' "$command" | grep -Eqi 'Migrations/.*\.cs' && printf '%s' "$command" | grep -Eqi '(cat |>|tee |touch )' && ! printf '%s' "$command" | grep -Eqi 'dotnet[[:space:]]+ef'; then
  deny "Do not hand-write EF Core migration files. Use: dotnet ef migrations add <Name>"
fi

allow
