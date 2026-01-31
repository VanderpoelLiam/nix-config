{ config, lib, ... }:
let
  cfg = config.services.tailscale;
in
{
  config = lib.mkIf cfg.enable {
    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    services.tailscale = {
      useRoutingFeatures = "server";
    };
  };
}
