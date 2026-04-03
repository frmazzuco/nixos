#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$script_dir/lib.sh"

repo_root="$(repo_root_from "${BASH_SOURCE[0]}")"
module_file="$repo_root/modules/services/ambient-assistant.nix"

require_fixed 'requires = [ "gemma4-e4b-server.service" ];' "$module_file"
require_fixed 'after = [ "gemma4-e4b-server.service" ];' "$module_file"
require_fixed 'AMBIENT_ASSISTANT_PROVIDER_KIND=openai-compat' "$module_file"
require_fixed 'AMBIENT_ASSISTANT_PROVIDER_BASE_URL=http://127.0.0.1:18083/v1' "$module_file"
require_fixed 'AMBIENT_ASSISTANT_MODEL=gemma-4-e4b-it-Q8_0.gguf' "$module_file"
require_fixed 'AMBIENT_ASSISTANT_PROFILE=thinking-general' "$module_file"
require_fixed 'AMBIENT_ASSISTANT_MAX_TOOL_ROUNDS=24' "$module_file"
require_fixed 'AMBIENT_ASSISTANT_SEERR_BASE_URL=http://127.0.0.1:5055' "$module_file"
require_fixed 'AMBIENT_ASSISTANT_SEERR_SETTINGS_FILE=%h/arr/config/jellyseerr/settings.json' "$module_file"
require_fixed 'openai-agents' "$module_file"
reject_fixed 'AMBIENT_ASSISTANT_PROVIDER_KIND=openai-api' "$module_file"
reject_fixed 'AMBIENT_ASSISTANT_MODEL=gpt-5.4-nano' "$module_file"
reject_fixed 'pkgs.bws' "$module_file"

printf 'ambient-assistant service contract OK\n'
