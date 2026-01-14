{ config, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./services
  ];

  networking.hostName = "hyperion";

  sops = {
    defaultSopsFile = ../../../secrets/hyperion.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";

    secrets = {
      cloudflare_api_token = {
        owner = "caddy";
        group = "caddy";
      };
      pihole_password = {
        mode = "0400";
      };
    };
  };

  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;

    # Always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];

    # Allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];

    # For Tailscale exit nodes
    checkReversePath = "loose";

    # Allow specific ports from local network (192.168.1.0/24)
    extraInputRules = ''
      # Allow Pi-hole DNS for local devices
      ip saddr 192.168.1.0/24 tcp dport 53 accept
      ip saddr 192.168.1.0/24 udp dport 53 accept

      # Caddy reverse proxy for accessing services via domain names
      ip saddr 192.168.1.0/24 tcp dport { 80, 443 } accept
    '';
  };

  system.stateVersion = "25.11";
}
