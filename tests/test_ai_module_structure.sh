#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$script_dir/lib.sh"

repo_root="$(repo_root_from "${BASH_SOURCE[0]}")"
common_file="$repo_root/modules/ai/common.nix"

require_fixed 'mkDownloadScript' "$common_file"
require_fixed 'mkUserService' "$common_file"
require_fixed 'llamaCppCuda' "$common_file"

for module in "$repo_root"/modules/ai/qwen*.nix; do
    require_fixed 'ai = import ./common.nix { inherit pkgs inputs config; };' "$module"
    reject_fixed 'unstablePackages = import inputs.nixpkgs-unstable' "$module"
    reject_fixed 'llamaCppCuda =' "$module"
    reject_fixed 'pkgs.python313Packages.huggingface-hub' "$module"
done

printf 'AI module structure contract OK\n'
