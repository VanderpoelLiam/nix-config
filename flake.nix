{
  description = "Darwin System Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
    homebrew-bundle = { url = "github:homebrew/homebrew-bundle"; flake = false; };
  };
  outputs = inputs @ {
    nixpkgs,
    home-manager,
    darwin,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    homebrew-bundle,
    ...
  }: let
    userConfig = import ./user-config.nix;
  in {
    darwinConfigurations.${userConfig.hostname} = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };
      specialArgs = { inherit inputs userConfig; };
      modules = [
        nix-homebrew.darwinModules.nix-homebrew
        ./modules/darwin
        home-manager.darwinModules.home-manager
        {
          users.users.${userConfig.username}.home = "/Users/${userConfig.username}";
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit userConfig; };
            users.${userConfig.username}.imports = [./modules/home-manager];
          };
        }
      ];
    };
  };
}
