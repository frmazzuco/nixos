#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$script_dir/lib.sh"

repo_root="$(repo_root_from "${BASH_SOURCE[0]}")"
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
