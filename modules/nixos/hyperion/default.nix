{ config, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./services
  ];

  networking.hostName = "hyperion";

  # Enable Podman for OCI containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  sops = {
    defaultSopsFile = ../../../secrets/hyperion.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";

    secrets = {
      cloudflare_api_token = { };
      pihole_password = { };
    };
  };

  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;

    trustedInterfaces = [ "tailscale0" ];
    checkReversePath = "loose";
    allowedUDPPorts = [ config.services.tailscale.port ];

    extraInputRules = ''
      ip saddr 192.168.1.0/24 tcp dport { 53, 80, 443 } accept
      ip saddr 192.168.1.0/24 udp dport 53 accept
    '';
  };

  system.stateVersion = "25.11";
}
