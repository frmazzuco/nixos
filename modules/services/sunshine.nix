{ config, ... }:
let
  # Keep the first-run admin UI local to the host instead of exposing it on the tailnet.
  sunshineTcpPorts = [
    47984
    47989
    48010
  ];

  sunshineUdpPorts = [
    47998
    47999
    48000
    48002
    48010
  ];
in
{
  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    openFirewall = false;
    settings = {
      av1_mode = 1;
      capture = "kms";
      encoder = "software";
      hevc_mode = 1;
    };
  };

  users.users.${config.workstation.userName}.extraGroups = [ "input" ];

  services.udev.extraRules = ''
    # Match Sunshine's documented Linux setup so Moonlight input can create virtual devices.
    KERNEL=="uinput", SUBSYSTEM=="misc", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput", TAG+="uaccess"
  '';

  services.avahi = {
    openFirewall = false;
    publish = {
      enable = false;
      userServices = false;
    };
  };

  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = sunshineTcpPorts;
    allowedUDPPorts = sunshineUdpPorts;
  };
}
