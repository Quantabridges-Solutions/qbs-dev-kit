#!/usr/bin/env bash
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/skills/scaffold-saas-project/scripts/scaffold.sh" "$@"
