{ ... }:
{
  imports = [
    ./host-context.nix
    ./base.nix
    ./maintenance.nix
    ./desktop.nix
    ./appearance.nix
    ./packages.nix
    ./quickshell-core.nix
  ];
}
