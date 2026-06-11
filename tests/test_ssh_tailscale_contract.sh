#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$script_dir/lib.sh"

repo_root="$(repo_root_from "${BASH_SOURCE[0]}")"
base_file="$repo_root/modules/common/base.nix"
desktop_file="$repo_root/modules/common/desktop.nix"

require_fixed 'services.openssh = {' "$base_file"
require_fixed 'openFirewall = false;' "$base_file"
require_fixed 'PermitRootLogin = "no";' "$base_file"
require_fixed 'PubkeyAuthentication = true;' "$base_file"

require_fixed 'networking.firewall.interfaces.tailscale0.allowedTCPPorts' "$desktop_file"
require_fixed '22' "$desktop_file"
require_fixed '3389' "$desktop_file"

printf 'SSH Tailscale contract OK\n'
