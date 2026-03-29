#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$script_dir/lib.sh"

repo_root="$(repo_root_from "${BASH_SOURCE[0]}")"
module_file="$repo_root/modules/services/orico-storage.nix"

[[ -f "$module_file" ]] || fail "modulo ausente: ${module_file#$repo_root/}"

require_fixed 'boot.swraid = {' "$module_file"
require_fixed 'enable = true;' "$module_file"
require_fixed 'AUTO +all' "$module_file"
require_fixed 'ARRAY /dev/md127 metadata=1.2 UUID=97eba8d8:75a29d0c:0246fa54:bb7be45e' "$module_file"
require_fixed '"/mnt/orico-storage"' "$module_file"
require_fixed '"/dev/md127"' "$module_file"
require_fixed '"x-systemd.automount"' "$module_file"
require_fixed '"nofail"' "$module_file"

printf 'Orico storage contract OK\n'
