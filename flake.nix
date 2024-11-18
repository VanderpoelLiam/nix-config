{
  description = "Darwin System Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, darwin, ... }: {
    darwinConfigurations = let
      userConfig = import ./user-config.nix;
    in
    {
      "${userConfig.hostname}" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        pkgs = import nixpkgs { system = "aarch64-darwin"; };
        modules = [
          ./modules/darwin
        ];
      };
    };
  };
}
