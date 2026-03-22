#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
common_file="$repo_root/modules/ai/common.nix"

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

require_fixed 'mkDownloadScript' "$common_file"
require_fixed 'mkUserService' "$common_file"
require_fixed 'llamaCppCuda' "$common_file"

for module in "$repo_root"/modules/ai/qwen*.nix; do
    require_fixed 'ai = import ./common.nix { inherit pkgs inputs; };' "$module"
    reject_fixed 'unstablePackages = import inputs.nixpkgs-unstable' "$module"
    reject_fixed 'llamaCppCuda =' "$module"
    reject_fixed 'pkgs.python313Packages.huggingface-hub' "$module"
done

printf 'AI module structure contract OK\n'
