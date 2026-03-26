{ pkgs, inputs, ... }:
let
  unstablePackages = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
  agsPackages = inputs.ags.packages.${pkgs.stdenv.hostPlatform.system};
  walkerPackages = inputs.walker.packages.${pkgs.stdenv.hostPlatform.system};
  elephantPackages = inputs.elephant.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.ELEPHANT_PROVIDER_DIR = "${elephantPackages.default}/lib/elephant/providers";

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
    cudaPackages.cuda_cudart
    cudaPackages.cuda_nvcc
    pkg-config
    just
    python3
    ripgrep
    fd
    stow
    eza
    fzf
    zoxide
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
    discord
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
    walkerPackages.walker
    elephantPackages.default
    agsPackages.agsFull
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
    phinger-cursors
  ];
}
