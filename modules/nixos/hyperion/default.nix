{ config, pkgs, ... }:
{
  imports = [
    ./hardware.nix
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
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  # Enable services
  services.openssh.enable = true;
  services.caddy.enable = true;
  services.tailscale.enable = true;
  services.pihole.enable = true;
  services.homeassistant.enable = true;
  services.glance.enable = true;
  services.koifit.enable = true;
  services.sonarr.enable = true;
  services.radarr.enable = true;
  services.prowlarr.enable = true;
  services.jellyseerr.enable = true;
  services.jellyfin.enable = true;
  services.qbittorrent.enable = true;

  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    allowedUDPPorts = [ config.services.tailscale.port ];

    extraInputRules = ''
      ip saddr 192.168.1.0/24 tcp dport { 22, 53, 80, 443 } accept
      ip saddr 192.168.1.0/24 udp dport 53 accept
    '';
  };

  system.stateVersion = "25.11";
}
