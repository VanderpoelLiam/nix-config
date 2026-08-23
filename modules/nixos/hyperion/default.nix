{ config, pkgs, userConfig, ... }:
{
  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  networking.hostName = "hyperion";
  time.timeZone = userConfig.global.timezone;

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = [ pkgs.ghostty.terminfo ];

  # Enable Podman for OCI containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = false;
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

  services.caddy.enable = true;

  services.tailscale = {
    enable = true;
    extraSetFlags = [
      "--advertise-routes=192.168.1.111/32"
      "--advertise-exit-node"
    ];
  };
  services.pihole.enable = true;
  services.mosquitto.enable = true;
  services.homeassistant.enable = true;
  services.dashboard.enable = true;
  services.koifit.enable = true;

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
    dates = "monthly";
  };
  
  system.stateVersion = "25.11";
}
