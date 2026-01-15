{ config, ... }:
{
  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:latest";
    ports = [
      "53:53/tcp"
      "53:53/udp"
      "8081:80/tcp"
    ];
    environment = {
      TZ = "Europe/Zurich";
      FTLCONF_dns_listeningMode = "all";
      FTLCONF_webserver_api_password_FILE = "/run/secrets/pihole_password";
    };
    volumes = [
      "/var/lib/pihole:/etc/pihole"
      "${config.sops.secrets.pihole_password.path}:/run/secrets/pihole_password:ro"
    ];
  };

  systemd.services.podman-pihole.serviceConfig = {
    AmbientCapabilities = [ "CAP_SYS_TIME" "CAP_SYS_NICE" ];
    CapabilityBoundingSet = [ "CAP_SYS_TIME" "CAP_SYS_NICE" ];
  };
}
