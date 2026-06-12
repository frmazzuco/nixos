#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$script_dir/lib.sh"

repo_root="$(repo_root_from "${BASH_SOURCE[0]}")"

# --- backups ---

services_default="$repo_root/modules/services/default.nix"
backup_file="$repo_root/modules/services/backups.nix"
doc_file="$repo_root/docs/operations/backups.md"

require_fixed './backups.nix' "$services_default"
require_fixed 'services.restic.backups.workstation-local' "$backup_file"
require_fixed '/mnt/orico-storage/Backups/workstation-restic' "$backup_file"
require_fixed 'pkgs.bitwarden-cli' "$backup_file"
require_fixed 'restic-workstation-local-sync-password' "$backup_file"
require_fixed 'BITWARDEN_ITEM:-linux' "$backup_file"
require_fixed '.config/restic/workstation-local-password' "$backup_file"
require_fixed 'initialize = true;' "$backup_file"
require_fixed 'OnCalendar = "03:30";' "$backup_file"
require_fixed '--keep-daily 7' "$backup_file"
require_fixed '--with-cache' "$backup_file"
require_fixed 'bw get password linux' "$doc_file"
require_fixed 'restic-workstation-local-sync-password' "$doc_file"
require_fixed 'Restore smoke' "$doc_file"
require_fixed 'restic-workstation-local restore latest' "$doc_file"

printf 'Backup contract OK\n'

# --- manutencao ---

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

# --- armazenamento orico ---

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

# --- bluetooth ---

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

# --- desktop remoto ---

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
require_fixed 'cudaSupport = true;' "$sunshine_file"
require_fixed 'encoder = "nvenc";' "$sunshine_file"
require_fixed 'capture = "kms";' "$sunshine_file"
require_fixed 'hevc_mode = 2;' "$sunshine_file"
require_fixed 'av1_mode = 1;' "$sunshine_file"
require_fixed 'systemd.user.services.sunshine-microphone-source' "$sunshine_file"
require_fixed 'wants = [' "$sunshine_file"
require_fixed 'Restart = "on-failure";' "$sunshine_file"
require_fixed 'device.description=Sunshine_Microphone' "$sunshine_file"
require_fixed 'pactl set-default-source sunshine_microphone' "$sunshine_file"
require_fixed 'services.udev.extraRules = ' "$sunshine_file"
require_fixed 'KERNEL=="uinput"' "$sunshine_file"
require_fixed 'extraGroups = [ "input" ];' "$sunshine_file"
require_fixed 'GROUP="input"' "$sunshine_file"
require_fixed 'MODE="0660"' "$sunshine_file"
require_fixed 'TAG+="uaccess"' "$sunshine_file"

require_fixed 'https://localhost:47990' "$doc_file"
require_fixed 'adicionar o host manualmente' "$doc_file"
require_fixed 'Sunshine_Microphone' "$doc_file"
require_fixed 'teclado e mouse sao enviados automaticamente' "$doc_file"

printf 'Remote desktop contract OK\n'

# --- notificacoes do desktop ---

flake_file="$repo_root/flake.nix"
packages_file="$repo_root/modules/common/packages.nix"

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

# --- quickshell ui ---

migration_doc="$repo_root/docs/quickshell-migration.md"

expected_widget_targets() {
    printf '%s\n' \
        calendar \
        focustime \
        music \
        monitors \
        network \
        stewart \
        system \
        themepicker \
        wallpaper \
        | sort -u
}

documented_widget_targets() {
    awk '
        /^### Widgets portados$/ { in_section=1; next }
        /^## / && in_section { exit }
        /^### / && in_section { exit }
        in_section && /^- / {
            gsub(/`/, "", $2)
            print $2
        }
    ' "$migration_doc" | sort -u
}

require_fixed 'nerd-fonts.jetbrains-mono' "$base_file"
require_fixed 'nerd-fonts.iosevka' "$base_file"
diff -u <(expected_widget_targets) <(documented_widget_targets) >/dev/null || \
    fail "os widgets documentados no guia de migracao estao fora de sincronia"

printf 'Quickshell UI contract OK\n'

# --- ssh via tailscale ---

base_file="$repo_root/modules/common/base.nix"
desktop_file="$repo_root/modules/common/desktop.nix"

require_fixed 'services.openssh = {' "$base_file"
require_fixed 'openFirewall = false;' "$base_file"
require_fixed 'PermitRootLogin = "no";' "$base_file"
require_fixed 'PubkeyAuthentication = true;' "$base_file"

require_fixed 'networking.firewall.interfaces.tailscale0.allowedTCPPorts = [' "$desktop_file"
require_fixed '    22' "$desktop_file"
require_fixed '    3389' "$desktop_file"

printf 'SSH Tailscale contract OK\n'

# --- sudo sem senha apenas para nixos-rebuild ---

require_fixed 'security.sudo.extraRules' "$base_file"
require_fixed 'command = "/run/current-system/sw/bin/nixos-rebuild";' "$base_file"
require_fixed '"NOPASSWD"' "$base_file"

printf 'Sudo nixos-rebuild contract OK\n'

printf 'Host contracts OK\n'
