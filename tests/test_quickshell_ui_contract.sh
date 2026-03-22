#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$script_dir/lib.sh"

repo_root="$(repo_root_from "${BASH_SOURCE[0]}")"
base_file="$repo_root/modules/common/base.nix"
migration_doc="$repo_root/docs/quickshell-migration.md"

expected_widget_targets() {
    printf '%s\n' \
        assistant \
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
