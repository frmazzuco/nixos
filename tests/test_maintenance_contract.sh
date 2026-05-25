#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$script_dir/lib.sh"

repo_root="$(repo_root_from "${BASH_SOURCE[0]}")"
common_default="$repo_root/modules/common/default.nix"
base_file="$repo_root/modules/common/base.nix"
maintenance_file="$repo_root/modules/common/maintenance.nix"

require_fixed './maintenance.nix' "$common_default"
require_fixed 'nix.gc = {' "$maintenance_file"
require_fixed 'options = "--delete-older-than 30d";' "$maintenance_file"
require_fixed 'nix.optimise = {' "$maintenance_file"
require_fixed 'services.journald.extraConfig' "$maintenance_file"
require_fixed 'SystemMaxUse=1G' "$maintenance_file"
require_fixed 'MaxRetentionSec=14day' "$maintenance_file"
reject_fixed 'nix.gc = {' "$base_file"
reject_fixed 'nix.optimise = {' "$base_file"

printf 'Maintenance contract OK\n'
