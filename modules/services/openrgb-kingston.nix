{ pkgs, inputs, ... }:
let
  unstablePackages = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  # Kingston Fury RAM RGB - set to white on boot
  systemd.services.openrgb-kingston = {
    description = "Set Kingston Fury RAM RGB to white";
    wantedBy = [ "multi-user.target" ];
    wants = [ "systemd-udev-settle.service" ];
    after = [
      "local-fs.target"
      "systemd-udev-settle.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${unstablePackages.openrgb}/bin/openrgb --noautoconnect --device "Kingston Fury DDR5 DRAM" --mode static --color FFFFFF
    '';
  };
}
