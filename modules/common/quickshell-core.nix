{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    quickshell
    qt6.qtmultimedia
    qt6.qt5compat
    brightnessctl
    socat
    cliphist
    swww
    ffmpeg
    imagemagick
    libnotify
    curl
    bc
    matugen
  ];
}
