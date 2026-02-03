{ pkgs, ... }:
{
  imports = [
    ../../shared/home.nix
    ./apps
  ];
}

