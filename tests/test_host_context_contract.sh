#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$script_dir/lib.sh"

repo_root="$(repo_root_from "${BASH_SOURCE[0]}")"
host_context_file="$repo_root/modules/common/host-context.nix"

require_fixed 'options.workstation' "$host_context_file"
require_fixed 'userName = lib.mkOption' "$host_context_file"
require_fixed 'userHome = lib.mkOption' "$host_context_file"
require_fixed 'repoRoot = lib.mkOption' "$host_context_file"

literal_hits="$(
  rg -n '/home/fmazzuco|users\\.users\\.fmazzuco| -o fmazzuco\\b|fmazzuco:users' \
    "$repo_root/modules" \
    "$repo_root/hosts" \
    -g '*.nix' \
    -g '!modules/common/host-context.nix' || true
)"

if [[ -n "$literal_hits" ]]; then
  printf 'FAIL: literais do host ainda espalhados em modulos/hosts:\n%s\n' "$literal_hits" >&2
  exit 1
fi

printf 'Host context contract OK\n'
