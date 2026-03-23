#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$script_dir/lib.sh"

repo_root="$(repo_root_from "${BASH_SOURCE[0]}")"
flake_file="$repo_root/flake.nix"
packages_file="$repo_root/modules/common/packages.nix"
readme_file="$repo_root/README.md"
host_map_file="$repo_root/docs/architecture/host-map.md"

require_fixed 'ags = {' "$flake_file"
require_fixed 'url = "github:aylur/ags";' "$flake_file"
require_fixed 'agsPackages = inputs.ags.packages.${pkgs.stdenv.hostPlatform.system};' "$packages_file"
require_fixed 'agsPackages.agsFull' "$packages_file"
require_fixed 'stow' "$packages_file"
reject_fixed 'mako' "$packages_file"
reject_fixed 'astal.astal4' "$packages_file"
reject_fixed 'astal.io' "$packages_file"
reject_fixed 'astal.gjs' "$packages_file"
reject_fixed 'astal.notifd' "$packages_file"
require_fixed 'Input dedicado do upstream `github:aylur/ags` para o runtime de notificacoes do desktop.' "$readme_file"
require_fixed 'O runtime de notificacoes usa `ags` do sistema; a configuracao e o launcher da sessao Hyprland ficam no repo de dotfiles.' "$readme_file"
require_fixed 'O runtime de notificacoes usa `ags` do sistema; a configuracao do app e o launcher da sessao continuam no repo de dotfiles.' "$host_map_file"

printf 'Desktop notification contract OK\n'
