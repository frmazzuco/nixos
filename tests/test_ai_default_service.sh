#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$script_dir/lib.sh"

repo_root="$(repo_root_from "${BASH_SOURCE[0]}")"
cd "$repo_root"

mapfile -t default_modules < <(rg -l 'wantedBy = \[ "default.target" \];' modules/ai/*.nix | rg -v '/(common|default)\\.nix$' | sort)

if [ "${#default_modules[@]}" -ne 1 ]; then
  fail "esperado exatamente um modulo AI com wantedBy = [\"default.target\"], encontrados ${#default_modules[@]} (${default_modules[*]:-<none>})"
fi

expected_default="modules/ai/gemma4-e4b.nix"
if [ "${default_modules[0]}" != "$expected_default" ]; then
  fail "modulo AI default esperado: $expected_default; encontrado: ${default_modules[0]}"
fi

for module in modules/ai/*.nix; do
  [[ "$module" == modules/ai/common.nix || "$module" == modules/ai/default.nix ]] && continue
  reject_fixed 'qwen35-a3b-server.service' "$module"
  reject_fixed 'qwen35-27b-server.service' "$module"
done

printf 'AI default service contract OK\n'
