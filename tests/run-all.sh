#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
shopt -s nullglob
test_scripts=("$script_dir"/test_*.sh)

if [ "${#test_scripts[@]}" -eq 0 ]; then
  printf 'FAIL: nenhum contract test encontrado em %s\n' "$script_dir" >&2
  exit 1
fi

for test_script in "${test_scripts[@]}"; do
  bash "$test_script"
done
