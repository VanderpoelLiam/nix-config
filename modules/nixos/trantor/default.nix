{ config, pkgs, userConfig, ... }:
{
  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  networking.hostName = "trantor";
  time.timeZone = userConfig.global.timezone;

  security.sudo.wheelNeedsPassword = false;

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  environment.systemPackages = [ pkgs.ghostty.terminfo ];

  # Enable Podman for OCI containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.caddy.enable = true;
  services.tailscale.enable = true;
  services.sonarr.enable = true;
  services.radarr.enable = true;
  services.prowlarr.enable = true;
  services.seerr.enable = true;
  services.jellyfin.enable = true;
  services.torrent.enable = true;

  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    allowedUDPPorts = [ config.services.tailscale.port ];

    extraInputRules = ''
      ip saddr 192.168.1.0/24 tcp dport { 22, 80, 443, 8096 } accept
    '';
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:VanderpoelLiam/nix-config#trantor";
    allowReboot = true;
    dates = "monthly";
  };

  system.stateVersion = "25.11";
}
