{ config, lib, ... }:
let
  cfg = config.services.tailscale;
in
{
  config = lib.mkIf cfg.enable {
    # Enable exit node 
    services.tailscale.useRoutingFeatures = "server";
  };
}
