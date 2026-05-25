{ config, pkgs, ... }:
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
  systemd.user.services.sunshine-microphone-source = {
    description = "Virtual PipeWire microphone source for Discord during Sunshine sessions";
    after = [
      "pipewire-pulse.service"
      "wireplumber.service"
    ];
    wants = [
      "pipewire-pulse.service"
      "wireplumber.service"
    ];
    wantedBy = [ "default.target" ];
    path = with pkgs; [
      gawk
      gnugrep
      gnused
      pipewire
      pulseaudio
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "2s";
    };
    script = ''
      set -eu

      for _ in 1 2 3 4 5 6 7 8 9 10; do
        pactl info >/dev/null 2>&1 && break
        sleep 1
      done
      pactl info >/dev/null

      if ! pactl list short sources | grep -q $'\tsunshine_microphone\t'; then
        pactl load-module module-null-sink \
          sink_name=sunshine_microphone \
          media.class=Audio/Source/Virtual \
          sink_properties=device.description=Sunshine_Microphone >/dev/null
      fi

      default_source="$(pactl info | sed -n 's/^Default Source: //p')"
      if [ "$default_source" = "sunshine_microphone" ] || [ -z "$default_source" ]; then
        default_source="$(pactl list short sources | awk '$2 != "sunshine_microphone" && $2 !~ /\.monitor$/ { print $2; exit }')"
      fi

      if [ -n "$default_source" ] && [ "$default_source" != "sunshine_microphone" ]; then
        pw-link "$default_source:capture_FL" sunshine_microphone:input_FL 2>/dev/null || true
        pw-link "$default_source:capture_FR" sunshine_microphone:input_FR 2>/dev/null || true
      fi

      pactl set-default-source sunshine_microphone
    '';
  };

  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    openFirewall = false;
    package = pkgs.sunshine.override {
      cudaSupport = true;
    };
    settings = {
      av1_mode = 1;
      capture = "kms";
      encoder = "nvenc";
      hevc_mode = 2;
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
