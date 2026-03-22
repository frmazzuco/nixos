{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/ai
    ../../modules/compat
    ../../modules/services
  ];

  networking.hostName = "nixos";
  system.stateVersion = "25.11";
}
