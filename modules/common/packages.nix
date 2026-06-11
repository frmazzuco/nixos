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
  claudeCodeLatest = pkgs.stdenvNoCC.mkDerivation {
    pname = "claude-code";
    version = "2.1.172";

    src = pkgs.fetchurl {
      url = "https://downloads.claude.ai/claude-code-releases/2.1.172/linux-x64/claude";
      hash = "sha256-wJFd0WkdVpruvHl4sS4ClxgyNoXsDdS1xqRTEI1r4fc=";
    };

    dontUnpack = true;
    dontBuild = true;
    dontStrip = true;
    strictDeps = true;

    nativeBuildInputs =
      with pkgs;
      [
        installShellFiles
        makeBinaryWrapper
      ]
      ++ pkgs.lib.optionals pkgs.stdenvNoCC.hostPlatform.isElf [
        autoPatchelfHook
      ];

    installPhase = ''
      runHook preInstall

      installBin $src

      wrapProgram $out/bin/claude \
        --set DISABLE_AUTOUPDATER 1 \
        --set-default FORCE_AUTOUPDATE_PLUGINS 1 \
        --set DISABLE_INSTALLATION_CHECKS 1 \
        --set USE_BUILTIN_RIPGREP 0 \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [ pkgs.alsa-lib ]} \
        --prefix PATH : ${
          pkgs.lib.makeBinPath [
            pkgs.procps
            pkgs.ripgrep
            pkgs.bubblewrap
            pkgs.socat
          ]
        }

      runHook postInstall
    '';

    doInstallCheck = true;
    nativeInstallCheckInputs = with pkgs; [
      writableTmpDirAsHomeHook
      versionCheckHook
    ];
    versionCheckKeepEnvironment = [ "HOME" ];
    versionCheckProgramArg = "--version";

    meta = {
      description = "Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster";
      homepage = "https://github.com/anthropics/claude-code";
      downloadPage = "https://claude.com/product/claude-code";
      changelog = "https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md";
      license = pkgs.lib.licenses.unfree;
      mainProgram = "claude";
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with pkgs.lib.sourceTypes; [ binaryNativeCode ];
    };
  };
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
    claudeCodeLatest
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
