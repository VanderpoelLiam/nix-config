{ config, lib, pkgs, ... }:
let
  cfg = config.services.tailscale;
in
{
  config = lib.mkIf cfg.enable {
    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    services.tailscale = {
      useRoutingFeatures = "server";
    };

    # UDP GRO optimization for subnet routers and exit nodes
    services.networkd-dispatcher = {
      enable = true;
      rules."50-tailscale" = {
        onState = [ "routable" ];
        script = ''
          ${pkgs.ethtool}/bin/ethtool -K enp1s0 rx-udp-gro-forwarding on rx-gro-list off
        '';
      };
    };
  };
}
