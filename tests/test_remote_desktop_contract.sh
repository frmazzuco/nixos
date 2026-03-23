#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$script_dir/lib.sh"

repo_root="$(repo_root_from "${BASH_SOURCE[0]}")"
sunshine_file="$repo_root/modules/services/sunshine.nix"
doc_file="$repo_root/docs/operations/remote-desktop.md"

require_fixed '47984' "$sunshine_file"
require_fixed '47989' "$sunshine_file"
require_fixed '48010' "$sunshine_file"
reject_fixed '    47990' "$sunshine_file"
require_fixed 'services.avahi = {' "$sunshine_file"
require_fixed 'openFirewall = false;' "$sunshine_file"
require_fixed 'publish = {' "$sunshine_file"
require_fixed 'enable = false;' "$sunshine_file"
require_fixed 'userServices = false;' "$sunshine_file"
require_fixed 'encoder = "software";' "$sunshine_file"
require_fixed 'capture = "kms";' "$sunshine_file"
require_fixed 'hevc_mode = 1;' "$sunshine_file"
require_fixed 'av1_mode = 1;' "$sunshine_file"
require_fixed 'services.udev.extraRules = ' "$sunshine_file"
require_fixed 'KERNEL=="uinput"' "$sunshine_file"
require_fixed 'extraGroups = [ "input" ];' "$sunshine_file"
require_fixed 'GROUP="input"' "$sunshine_file"
require_fixed 'MODE="0660"' "$sunshine_file"
require_fixed 'TAG+="uaccess"' "$sunshine_file"

require_fixed 'https://localhost:47990' "$doc_file"
require_fixed 'adicionar o host manualmente' "$doc_file"
require_fixed 'teclado e mouse sao enviados automaticamente' "$doc_file"

printf 'Remote desktop contract OK\n'
