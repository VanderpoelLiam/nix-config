{ config, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  networking.hostName = "hyperion";

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = [ pkgs.ghostty.terminfo ];

  # Tailscale UDP GRO optimization
  services.networkd-dispatcher = {
    enable = true;
    rules."50-tailscale" = {
      onState = [ "routable" ];
      script = ''
        ${pkgs.ethtool}/bin/ethtool -K enp1s0 rx-udp-gro-forwarding on rx-gro-list off
      '';
    };
  };

  # Enable Podman for OCI containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # services.caddy.enable = true;
  services.tailscale.enable = true;
  # services.pihole.enable = true;
  # services.homeassistant.enable = true;
  # services.glance.enable = true;
  # services.koifit.enable = true;
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

  system.autoUpgrade = {
    enable = true;
    flake = "github:VanderpoelLiam/nix-config#hyperion";
    allowReboot = true;
    dates = "04:00";
  };
  
  system.stateVersion = "25.11";
}
