{ pkgs, inputs, ... }:
let
  unstablePackages = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
  lutrisPackages = import inputs.nixpkgs-lutris {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
    overlays = [
      (_final: prev: {
        openldap = prev.openldap.overrideAttrs (_old: {
          doCheck = false;
        });
      })
    ];
  };
  agsPackages = inputs.ags.packages.${pkgs.stdenv.hostPlatform.system};
  walkerPackages = inputs.walker.packages.${pkgs.stdenv.hostPlatform.system};
  elephantPackages = inputs.elephant.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.ELEPHANT_PROVIDER_DIR = "${elephantPackages.default}/lib/elephant/providers";

  environment.systemPackages = with pkgs; [
    # --- Core & Shell ---
    bubblewrap
    zoxide
    atuin
    fzf
    eza
    fd
    ripgrep
    tree
    file
    unzip
    zip
    stow

    # --- CLI Tools ---
    git
    git-lfs
    gh
    jq
    yq-go
    curl
    bc
    just
    fastfetch
    btop

    # --- Development ---
    neovim
    tmux
    nodejs
    gcc
    gnumake
    cmake
    pkg-config
    python3
    nixd
    nixfmt-rfc-style
    kubectl

    # --- AI & Specialized ---
    unstablePackages.claude-code
    unstablePackages.opencode
    walkerPackages.walker
    elephantPackages.default
    agsPackages.agsFull

    # --- Graphics & Desktop ---
    ghostty
    hyprlock
    hyprpolkitagent
    networkmanagerapplet
    pavucontrol
    playerctl
    swww
    grim
    slurp
    satty
    imagemagick
    ffmpeg
    discord
    lutrisPackages.lutris
    umu-launcher
    winetricks
    unstablePackages.openrgb
    phinger-cursors

    # --- Utilities ---
    (writeShellScriptBin "pbcopy" ''
      exec ${wl-clipboard}/bin/wl-copy "$@"
    '')
    (writeShellScriptBin "pbpaste" ''
      exec ${wl-clipboard}/bin/wl-paste "$@"
    '')
  ];
}
