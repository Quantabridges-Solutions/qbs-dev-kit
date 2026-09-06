#!/usr/bin/env bash
# Resolve the QBS Dev Kit checkout. Source this file; call qbs_find_kit_root.
# Order: QBS_KIT_ROOT → ~/.config/qbs-dev-kit/kit-root → walk up from caller → common clone paths.

qbs_find_kit_root() {
  local candidate

  if [[ -n "${QBS_KIT_ROOT:-}" && -d "${QBS_KIT_ROOT}/templates" && -d "${QBS_KIT_ROOT}/skills" ]]; then
    printf '%s\n' "$QBS_KIT_ROOT"
    return 0
  fi

  if [[ -f "${HOME}/.config/qbs-dev-kit/kit-root" ]]; then
    candidate="$(tr -d '[:space:]' < "${HOME}/.config/qbs-dev-kit/kit-root")"
    if [[ -d "${candidate}/templates" && -d "${candidate}/skills" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  fi

  if [[ -n "${1:-}" ]]; then
    candidate="$(cd "$1" && pwd)"
    while [[ "$candidate" != "/" ]]; do
      if [[ -d "${candidate}/templates" && -d "${candidate}/skills" && -f "${candidate}/install.sh" ]]; then
        printf '%s\n' "$candidate"
        return 0
      fi
      candidate="$(dirname "$candidate")"
    done
  fi

  for candidate in \
    "${HOME}/source/quantabridges/qbs-dev-kit" \
    "${HOME}/source/qbs-dev-kit" \
    "${HOME}/qbs-dev-kit"; do
    if [[ -d "${candidate}/templates" && -d "${candidate}/skills" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}
