{
  description = "Nix Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
    homebrew-bundle = { url = "github:homebrew/homebrew-bundle"; flake = false; };
  };

  outputs = { ... }@inputs:
    with inputs;
    let
      userConfig = import ./user-config.nix;
      username = userConfig.global.username;
    in {
      darwinConfigurations."Liams-MacBook-Pro" = darwin.lib.darwinSystem {
        system = userConfig.machines."Liams-MacBook-Pro".system;
        pkgs = import nixpkgs-darwin {
          system = userConfig.machines."Liams-MacBook-Pro".system;
          config.allowUnfree = true;
        };
        specialArgs = {
          inherit inputs userConfig username;
          hostname = "Liams-MacBook-Pro";
        };
        modules = [
          nix-homebrew.darwinModules.nix-homebrew
          ./modules/darwin/Liams-MacBook-Pro
          home-manager.darwinModules.home-manager
          {
            users.users.${username}.home = "/Users/${username}";
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit userConfig; hostname = "Liams-MacBook-Pro"; };
              users.${username}.imports = [ ./modules/darwin/Liams-MacBook-Pro/home.nix ];
            };
          }
        ];
      };
    };
}
