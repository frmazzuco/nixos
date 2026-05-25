{ config, pkgs, ... }:
let
  userName = config.workstation.userName;
  userHome = config.workstation.userHome;
  mediaRoot = "/mnt/orico-storage/Media";
  repository = "/mnt/orico-storage/Backups/workstation-restic";
  passwordFile = "${userHome}/.config/restic/workstation-local-password";
  syncPassword = pkgs.writeShellScriptBin "restic-workstation-local-sync-password" ''
    set -euo pipefail

    if [ "$(${pkgs.coreutils}/bin/id -un)" != "${userName}" ]; then
      echo "Rode como ${userName}, sem sudo" >&2
      exit 1
    fi

    item="''${BITWARDEN_ITEM:-linux}"
    ${pkgs.coreutils}/bin/install -d -m 0700 ${userHome}/.config/restic
    tmp="$(${pkgs.coreutils}/bin/mktemp)"
    trap 'rm -f "$tmp"' EXIT

    ${pkgs.bitwarden-cli}/bin/bw get password "$item" > "$tmp"
    ${pkgs.coreutils}/bin/install -m 0600 "$tmp" ${passwordFile}
    echo "Senha do restic atualizada em ${passwordFile} a partir do item Bitwarden: $item"
  '';
in
{
  environment.systemPackages = [
    pkgs.restic
    pkgs.bitwarden-cli
    syncPassword
  ];

  systemd.tmpfiles.rules = [
    "d ${userHome}/.config/restic 0700 ${userName} users -"
  ];

  services.restic.backups.workstation-local = {
    inherit passwordFile repository;
    initialize = true;
    inhibitsSleep = true;

    paths = [
      "${userHome}/repos"
      "${userHome}/arr/config"
      "${userHome}/arr/security"
      "${userHome}/jellyfin/config"
      "${userHome}/.ssh"
      "${userHome}/.secrets"
      "${userHome}/.config/cloudflared"
      "${userHome}/.config/sunshine"
    ];

    exclude = [
      "${userHome}/repos/*/.direnv"
      "${userHome}/repos/*/.pytest_cache"
      "${userHome}/repos/*/node_modules"
      "${userHome}/repos/*/result"
      "${userHome}/arr/config/*/logs"
      "${userHome}/jellyfin/config/log"
    ];

    backupPrepareCommand = ''
      if [ ! -d ${mediaRoot} ]; then
        echo "Volume ORICO nao montado em ${mediaRoot}; abortando backup restic" >&2
        exit 1
      fi
      ${pkgs.coreutils}/bin/install -d -m 0750 -o root -g root ${repository}
    '';

    timerConfig = {
      OnCalendar = "03:30";
      Persistent = true;
      RandomizedDelaySec = "45min";
    };

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];

    runCheck = true;
    checkOpts = [ "--with-cache" ];
  };
}
