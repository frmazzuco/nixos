{ config, pkgs, ... }:
let
  envFile = "${config.workstation.userHome}/.config/cloudflared/media-bws.env";
  startScript = pkgs.writeShellScript "cloudflared-media-tunnel-start" ''
    set -euo pipefail

    export HOME=${config.workstation.userHome}

    if [ -z "''${BWS_ACCESS_TOKEN:-}" ]; then
      echo "BWS_ACCESS_TOKEN ausente; configure ${envFile}" >&2
      exit 1
    fi

    secret_id="''${CLOUDFLARE_TUNNEL_BWS_SECRET_ID:-}"

    if [ -z "$secret_id" ]; then
      secret_key="''${CLOUDFLARE_TUNNEL_BWS_SECRET_KEY:-cloudflare}"
      secret_matches="$(${pkgs.bws}/bin/bws secret list | ${pkgs.jq}/bin/jq -c --arg key "$secret_key" '[.[] | select(.key == $key)]')"
      match_count="$(printf '%s' "$secret_matches" | ${pkgs.jq}/bin/jq 'length')"

      if [ "$match_count" -ne 1 ]; then
        echo "esperado exatamente um segredo BWS com key '$secret_key'; encontrados: $match_count" >&2
        exit 1
      fi

      secret_id="$(printf '%s' "$secret_matches" | ${pkgs.jq}/bin/jq -r '.[0].id')"
    fi

    tunnel_token="$(${pkgs.bws}/bin/bws secret get "$secret_id" | ${pkgs.jq}/bin/jq -r '.value')"

    if [ -z "$tunnel_token" ] || [ "$tunnel_token" = "null" ]; then
      echo "token do Cloudflare Tunnel vazio para o segredo BWS selecionado" >&2
      exit 1
    fi

    export TUNNEL_TOKEN="$tunnel_token"
    exec ${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run
  '';
in
{
  systemd.tmpfiles.rules = [
    "d ${config.workstation.userHome}/.config/cloudflared 0700 ${config.workstation.userName} users -"
  ];

  systemd.user.services.cloudflared-media-tunnel = {
    description = "Cloudflare Tunnel for Jellyfin and Seerr";
    wantedBy = [ "default.target" ];
    after = [ "network.target" ];
    wants = [ "network.target" ];
    path = with pkgs; [
      bash
      bws
      cloudflared
      jq
    ];

    serviceConfig = {
      EnvironmentFile = [ "-${envFile}" ];
      ExecStart = "${startScript}";
      Restart = "always";
      RestartSec = 10;
    };
  };
}
