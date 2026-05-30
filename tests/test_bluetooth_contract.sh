#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$script_dir/lib.sh"

repo_root="$(repo_root_from "${BASH_SOURCE[0]}")"
desktop_file="$repo_root/modules/common/desktop.nix"
readme_file="$repo_root/README.md"
host_map_file="$repo_root/docs/architecture/host-map.md"

require_fixed 'hardware.bluetooth = {' "$desktop_file"
require_fixed 'powerOnBoot = true;' "$desktop_file"
require_fixed 'services.blueman.enable = true;' "$desktop_file"
require_fixed 'services.upower.enable = true;' "$desktop_file"

require_fixed 'Bluetooth/BlueZ' "$readme_file"
require_fixed 'bluetooth.service' "$readme_file"
require_fixed 'bluetoothctl' "$readme_file"
require_fixed 'upower' "$readme_file"
require_fixed 'Bluetooth/BlueZ' "$host_map_file"
require_fixed 'UPower' "$host_map_file"

printf 'Bluetooth contract OK\n'
