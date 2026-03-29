#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$script_dir/lib.sh"

repo_root="$(repo_root_from "${BASH_SOURCE[0]}")"
module_file="$repo_root/modules/services/cloudflared-media-tunnel.nix"
entrypoint_file="$repo_root/modules/services/default.nix"
readme_file="$repo_root/README.md"
host_map_file="$repo_root/docs/architecture/host-map.md"

require_fixed 'systemd.user.services.cloudflared-media-tunnel' "$module_file"
require_fixed '.config/cloudflared/media-bws.env' "$module_file"
require_fixed "CLOUDFLARE_TUNNEL_BWS_SECRET_KEY:-cloudflare" "$module_file"
require_fixed 'export TUNNEL_TOKEN="$tunnel_token"' "$module_file"
require_fixed 'cloudflared tunnel --no-autoupdate run' "$module_file"
require_fixed 'Restart = "always";' "$module_file"

require_fixed './cloudflared-media-tunnel.nix' "$entrypoint_file"

require_fixed 'cloudflared-media-tunnel' "$readme_file"
require_fixed 'media-bws.env' "$readme_file"
require_fixed 'BWS_ACCESS_TOKEN' "$readme_file"
require_fixed 'Jellyfin e Seerr' "$readme_file"

require_fixed 'modules/services/cloudflared-media-tunnel.nix' "$host_map_file"
require_fixed 'media-bws.env' "$host_map_file"

printf 'Cloudflared media contract OK\n'
