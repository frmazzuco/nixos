{ pkgs, inputs, ... }:
let
  unstablePackages = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    bubblewrap
    git
    git-lfs
    gh
    neovim
    tmux
    zsh
    gcc
    gnumake
    cmake
    pkg-config
    just
    python3
    ripgrep
    fd
    eza
    fzf
    atuin
    jq
    yq-go
    tree
    file
    unzip
    zip
    nixd
    nixfmt-rfc-style
    ghostty
    kubectl
    xfce.xfce4-session
    xfce.xfconf
    xfce.xfce4-panel
    xfce.xfwm4
    xfce.xfdesktop
    xfce.xfce4-settings
    xfce.exo
    xfce.garcon
    xfce.xfce4-terminal
    xfce.thunar
    unstablePackages.claude-code
    unstablePackages.opencode
    (writeShellScriptBin "pbcopy" ''
      exec ${wl-clipboard}/bin/wl-copy "$@"
    '')
    (writeShellScriptBin "pbpaste" ''
      exec ${wl-clipboard}/bin/wl-paste "$@"
    '')
    nodejs
    rofi
    mako
    wl-clipboard
    grim
    slurp
    satty
    hyprlock
    hyprpolkitagent
    networkmanagerapplet
    pavucontrol
    playerctl
    btop
    unstablePackages.openrgb
  ];
}
