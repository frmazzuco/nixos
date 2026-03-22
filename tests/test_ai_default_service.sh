#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$script_dir/lib.sh"

repo_root="$(repo_root_from "${BASH_SOURCE[0]}")"
cd "$repo_root"

mapfile -t default_modules < <(rg -l 'wantedBy = \[ "default.target" \];' modules/ai/qwen*.nix | sort)

if [ "${#default_modules[@]}" -ne 1 ]; then
  fail "esperado exatamente um modulo AI com wantedBy = [\"default.target\"], encontrados ${#default_modules[@]} (${default_modules[*]:-<none>})"
fi

expected_default="modules/ai/qwen35-9b.nix"
if [ "${default_modules[0]}" != "$expected_default" ]; then
  fail "modulo AI default esperado: $expected_default; encontrado: ${default_modules[0]}"
fi

for module in modules/ai/qwen*.nix; do
  if [ "$(rg -o 'service"' -N "$module" | wc -l)" -ne 2 ]; then
    fail "esperado que $module conflite com exatamente dois servicos AI irmaos"
  fi
done

printf 'AI default service contract OK\n'
