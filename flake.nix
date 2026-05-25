{
  description = "NixOS configuration for fmazzuco workstations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.follows = "nixpkgs";
    mt7902-temp = {
      url = "github:OnlineLearningTutorials/mt7902_temp";
      flake = false;
    };
    nixpkgs-lutris.url = "github:NixOS/nixpkgs/68a8af93ff4297686cb68880845e61e5e2e41d92";
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    elephant.follows = "walker/elephant";
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      system = "x86_64-linux";
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./hosts/nixos
        ];
      };
    };
}
