#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$script_dir/lib.sh"

repo_root="$(repo_root_from "${BASH_SOURCE[0]}")"

for script_name in check test switch; do
  reject_fixed 'path:' "$repo_root/bin/$script_name"
done

require_fixed 'nix flake check "${repo_root}"' "$repo_root/bin/check"
require_fixed 'nixos-rebuild test --flake "${repo_root}#nixos"' "$repo_root/bin/test"
require_fixed 'nixos-rebuild switch --flake "${repo_root}#nixos"' "$repo_root/bin/switch"

printf 'Bin flake refs OK\n'
