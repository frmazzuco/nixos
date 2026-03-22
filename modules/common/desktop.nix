{ pkgs, config, ... }:
let
  xrdpXfceSession = pkgs.writeShellScript "xrdp-startxfce4" ''
    export PATH=${
      pkgs.lib.makeBinPath [
        pkgs.dbus
        pkgs.xfce.xfce4-session
        pkgs.xfce.xfconf
        pkgs.xfce.xfwm4
        pkgs.xfce.xfdesktop
        pkgs.xfce.xfce4-settings
        pkgs.xfce.exo
        pkgs.xfce.garcon
        pkgs.xfce.xfce4-panel
        pkgs.xfce.xfce4-terminal
        pkgs.xfce.thunar
      ]
    }:$PATH
    export XDG_CONFIG_DIRS="${pkgs.xfce.xfce4-session}/etc/xdg:${pkgs.xfce.garcon}/etc/xdg''${XDG_CONFIG_DIRS:+:$XDG_CONFIG_DIRS}"
    export XDG_DATA_DIRS="${pkgs.xfce.xfce4-session}/share:${pkgs.xfce.xfconf}/share:${pkgs.xfce.garcon}/share:${pkgs.xfce.exo}/share:${pkgs.xfce.xfce4-panel}/share:${pkgs.xfce.xfdesktop}/share:${pkgs.xfce.xfce4-settings}/share''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
    exec ${pkgs.xfce.xfce4-session}/bin/startxfce4
  '';
in
{
  services.xserver.enable = true;
  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
  };
  programs.hyprland.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      amdgpuBusId = "PCI:12@0:0:0";
      nvidiaBusId = "PCI:1@0:0:0";
    };
  };

  services.printing.enable = true;
  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 3389 ];

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "${xrdpXfceSession}";
  services.hardware.deepcool-digital-linux.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
}
