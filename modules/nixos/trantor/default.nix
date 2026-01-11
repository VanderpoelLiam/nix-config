{ config, ... }:
{
  imports = [ ./hardware.nix ];

  networking.hostName = "trantor";

  services.tailscale.enable = true;

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  system.stateVersion = "24.05";
}
