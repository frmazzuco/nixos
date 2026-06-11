#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$script_dir/lib.sh"

repo_root="$(repo_root_from "${BASH_SOURCE[0]}")"
module_file="$repo_root/modules/services/mt7902-driver.nix"
readme_file="$repo_root/README.md"
host_map_file="$repo_root/docs/architecture/host-map.md"

require_fixed 'mt7902BluetoothModules' "$module_file"
require_fixed 'BT_RAM_CODE_MT7902_1_1_hdr.bin' "$module_file"
require_fixed 'case 0x7902:' "$module_file"
require_fixed 'USB_DEVICE(0x13d3, 0x3596)' "$module_file"
require_fixed 'updates/mt7902-bluetooth/btmtk.ko' "$module_file"
require_fixed 'updates/mt7902-bluetooth/btusb.ko' "$module_file"
require_fixed 'options btusb reset=0' "$module_file"
require_fixed 'dev_id != 0x7902' "$module_file"
require_fixed 'msleep(1000);' "$module_file"
reject_fixed 'return -EOPNOTSUPP;' "$module_file"

require_fixed 'btusb`/`btmtk`' "$readme_file"
require_fixed 'btusb reset=0' "$readme_file"
require_fixed '0xfd98' "$readme_file"
require_fixed 'Wi-Fi/Bluetooth MT7902' "$readme_file"
require_fixed 'btusb`/`btmtk`' "$host_map_file"
require_fixed 'btusb reset=0' "$host_map_file"

printf 'MT7902 driver contract OK\n'
