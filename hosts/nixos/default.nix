{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common/base.nix
    ../../modules/common/desktop.nix
    ../../modules/common/packages.nix
    ../../modules/ai/qwen35-a3b.nix
    ../../modules/compat/user-dotfiles.nix
  ];

  networking.hostName = "nixos";
  system.stateVersion = "25.11";
}
