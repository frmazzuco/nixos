{ pkgs, ... }:
let
  swwwCompat = pkgs.writeShellScriptBin "swww" ''
    exec ${pkgs.awww}/bin/awww "$@"
  '';

  swwwDaemonCompat = pkgs.writeShellScriptBin "swww-daemon" ''
    exec ${pkgs.awww}/bin/awww-daemon "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
    quickshell
    qt6.qtmultimedia
    qt6.qt5compat
    brightnessctl
    socat
    cliphist
    awww
    swwwCompat
    swwwDaemonCompat
    ffmpeg
    imagemagick
    libnotify
    curl
    bc
    matugen
  ];
}
