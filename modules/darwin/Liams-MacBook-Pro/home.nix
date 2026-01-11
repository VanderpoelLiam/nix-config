{ pkgs, ... }:
{
  imports = [
    ../../home-manager/default.nix
    ./apps
  ];
}

