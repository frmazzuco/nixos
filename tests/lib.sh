#!/usr/bin/env bash
set -euo pipefail

repo_root_from() {
  local script_path="$1"
  cd "$(dirname "$script_path")/.." && pwd
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

require_fixed() {
  local needle="$1"
  local file="$2"

  rg -F -- "$needle" "$file" >/dev/null 2>&1 || fail "trecho ausente em $(basename "$file"): $needle"
}

reject_fixed() {
  local needle="$1"
  local file="$2"

  if rg -F -- "$needle" "$file" >/dev/null 2>&1; then
    fail "trecho redundante em $(basename "$file"): $needle"
  fi
}
