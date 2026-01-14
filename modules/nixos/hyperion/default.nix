{ config, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./services
  ];

  networking.hostName = "hyperion";
  networking.firewall.enable = true;

  system.stateVersion = "25.11";
}
