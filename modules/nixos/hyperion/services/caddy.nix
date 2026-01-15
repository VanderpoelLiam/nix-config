{ config, ... }:
{
  virtualisation.oci-containers.containers.caddy = {
    image = "ghcr.io/caddybuilds/caddy-cloudflare:latest";
    extraOptions = [ "--network=host" ];
    environmentFiles = [ config.sops.secrets.cloudflare_api_token.path ];
    volumes = [ "/var/lib/caddy/Caddyfile:/etc/caddy/Caddyfile" ];
  };

  systemd.services.podman-caddy.serviceConfig = {
    AmbientCapabilities = [ "CAP_NET_ADMIN" ];
    CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
  };
}
