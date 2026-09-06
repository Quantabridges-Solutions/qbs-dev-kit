#!/usr/bin/env bash
# afterFileEdit: warn when tenant-scoped EF queries omit OrganizationId.
set -euo pipefail

input="$(cat)"
file_path="$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("file_path",""))' 2>/dev/null || true)"

if [[ "$file_path" != *.cs ]]; then
  exit 0
fi

if [[ ! -f "$file_path" ]]; then
  exit 0
fi

# Skip entities, DTOs, migrations
case "$file_path" in
  */Migrations/*|*/DTOs/*|*/Dtos/*|*/Models/*|*/Entities/*) exit 0 ;;
esac

if ! grep -Eq 'DbSet|\.Where\(|FirstOrDefaultAsync|ToListAsync|FindAsync' "$file_path"; then
  exit 0
fi

if grep -Eq 'OrganizationId|ICurrentOrganization' "$file_path"; then
  exit 0
fi

# Likely a data-access file without tenancy — nudge the agent
python3 - <<'PY'
import json
msg = (
    "Edited C# file queries EF Core but does not mention OrganizationId / ICurrentOrganization. "
    "Tenant-scoped queries must filter by org from server context, not the request body. "
    "If this file is intentionally global (e.g. Identity, health), ignore this warning."
)
print(json.dumps({"additional_context": msg}))
PY
