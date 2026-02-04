{ pkgs, ... }:
{
  imports = [
    ../../shared/home.nix
    ../../shared/apps
    ./apps
  ];
}

