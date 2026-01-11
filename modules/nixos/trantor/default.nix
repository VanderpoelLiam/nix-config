{ ... }:
{
  imports = [
    ./hardware.nix
    ./services
  ];

  networking.hostName = "trantor";
  networking.firewall.enable = true;

  system.stateVersion = "24.05";
}
