{ config, lib, userConfig, ... }:
let
  cfg = config.services.caddy;
in
{
  config = lib.mkIf cfg.enable {
    virtualisation = {
      podman.enable = true;
      oci-containers.containers.caddy = {
        image = "ghcr.io/caddybuilds/caddy-cloudflare:latest";
        autoStart = true;
        extraOptions = [
          "--pull=newer"
          "--network=host"
          "--cap-add=NET_ADMIN"
        ];
        volumes = [
          "/var/lib/caddy/Caddyfile:/etc/caddy/Caddyfile"
          "/var/lib/caddy/data:/data"
          "/var/lib/caddy/config:/config"
        ];
        environmentFiles = [
          config.sops.secrets.cloudflare_api_token.path
        ];
      };
    };

    # Create Caddy data directory
    systemd.tmpfiles.rules = [
      "d /var/lib/caddy 0755 root root - -"
      "d /var/lib/caddy/data 0755 root root - -"
      "d /var/lib/caddy/config 0755 root root - -"
    ];

    # Configure ACME for wildcard certificate (Caddy handles this via acme_dns)
    security.acme = {
      acceptTerms = true;
      defaults.email = "${userConfig.global.gitEmail}";
    };

    # Open firewall ports for HTTP/HTTPS
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    networking.firewall.allowedUDPPorts = [ 443 ]; # For HTTP/3
  };
}
