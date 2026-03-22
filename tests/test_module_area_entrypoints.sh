#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
host_file="$repo_root/hosts/nixos/default.nix"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

require_fixed() {
  local needle="$1"
  local file="$2"

  rg -F -- "$needle" "$file" >/dev/null 2>&1 || fail "trecho ausente em $(basename "$file"): $needle"
}

for entrypoint in \
  "$repo_root/modules/common/default.nix" \
  "$repo_root/modules/ai/default.nix" \
  "$repo_root/modules/compat/default.nix" \
  "$repo_root/modules/services/default.nix"; do
  [[ -f "$entrypoint" ]] || fail "entrypoint ausente: ${entrypoint#$repo_root/}"
done

require_fixed '../../modules/common' "$host_file"
require_fixed '../../modules/ai' "$host_file"
require_fixed '../../modules/compat' "$host_file"
require_fixed '../../modules/services' "$host_file"

for stale_import in \
  '../../modules/common/host-context.nix' \
  '../../modules/common/base.nix' \
  '../../modules/common/desktop.nix' \
  '../../modules/common/packages.nix' \
  '../../modules/common/quickshell-core.nix' \
  '../../modules/ai/qwen35-a3b.nix' \
  '../../modules/ai/qwen35-9b.nix' \
  '../../modules/ai/qwen35-27b-unsloth.nix' \
  '../../modules/compat/user-dotfiles.nix' \
  '../../modules/services/ambient-assistant.nix' \
  '../../modules/services/openrgb-kingston.nix'; do
  if rg -F -- "$stale_import" "$host_file" >/dev/null 2>&1; then
    fail "import antigo ainda presente em hosts/nixos/default.nix: $stale_import"
  fi
done

require_fixed './host-context.nix' "$repo_root/modules/common/default.nix"
require_fixed './base.nix' "$repo_root/modules/common/default.nix"
require_fixed './desktop.nix' "$repo_root/modules/common/default.nix"
require_fixed './packages.nix' "$repo_root/modules/common/default.nix"
require_fixed './quickshell-core.nix' "$repo_root/modules/common/default.nix"

require_fixed './qwen35-a3b.nix' "$repo_root/modules/ai/default.nix"
require_fixed './qwen35-9b.nix' "$repo_root/modules/ai/default.nix"
require_fixed './qwen35-27b-unsloth.nix' "$repo_root/modules/ai/default.nix"

require_fixed './user-dotfiles.nix' "$repo_root/modules/compat/default.nix"
require_fixed './ambient-assistant.nix' "$repo_root/modules/services/default.nix"
require_fixed './openrgb-kingston.nix' "$repo_root/modules/services/default.nix"

printf 'Module area entrypoints OK\n'
