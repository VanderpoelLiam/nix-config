{
  description = "Darwin System Configuration";

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
    in {
      darwinConfigurations.${userConfig.hostname} = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        pkgs = import nixpkgs-darwin {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
        specialArgs = {
          inherit inputs;
          hostname = userConfig.hostname;
          system = "aarch64-darwin";
          username = userConfig.username;
        };
        modules = [
          nix-homebrew.darwinModules.nix-homebrew
          ./hosts/darwin
          home-manager.darwinModules.home-manager
          {
            users.users.${userConfig.username}.home = "/Users/${userConfig.username}";
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit userConfig; };
              users.${userConfig.username}.imports = [./hosts/darwin/home.nix];
            };
          }
        ];
      };
    };
  }
