{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common/base.nix
    ../../modules/common/desktop.nix
    ../../modules/common/packages.nix
    ../../modules/common/quickshell-core.nix
    ../../modules/ai/qwen35-a3b.nix
    ../../modules/ai/qwen35-9b.nix
    ../../modules/ai/qwen35-27b-unsloth.nix
    ../../modules/compat/user-dotfiles.nix
    ../../modules/services/openrgb-kingston.nix
  ];

  networking.hostName = "nixos";
  system.stateVersion = "25.11";
}
