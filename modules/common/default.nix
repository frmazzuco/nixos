{ ... }:
{
  imports = [
    ./host-context.nix
    ./base.nix
    ./desktop.nix
    ./appearance.nix
    ./packages.nix
    ./quickshell-core.nix
  ];
}
