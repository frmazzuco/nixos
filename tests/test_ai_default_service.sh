#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

mapfile -t default_modules < <(rg -l 'wantedBy = \[ "default.target" \];' modules/ai/*.nix | sort)

if [ "${#default_modules[@]}" -ne 1 ]; then
  printf 'Expected exactly one AI module with wantedBy = ["default.target"], found %s\n' "${#default_modules[@]}" >&2
  printf 'Modules: %s\n' "${default_modules[*]:-<none>}" >&2
  exit 1
fi

expected_default="modules/ai/qwen35-9b.nix"
if [ "${default_modules[0]}" != "$expected_default" ]; then
  printf 'Expected default AI service module %s, found %s\n' "$expected_default" "${default_modules[0]}" >&2
  exit 1
fi

for module in modules/ai/*.nix; do
  if [ "$(rg -o 'service"' -N "$module" | wc -l)" -ne 2 ]; then
    printf 'Expected %s to conflict with exactly two sibling AI services\n' "$module" >&2
    exit 1
  fi
done

printf 'AI default service contract OK\n'
