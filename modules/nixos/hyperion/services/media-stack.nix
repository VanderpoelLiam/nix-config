{ userConfig, ... }:
{
  virtualisation.oci-containers.containers = {
    prowlarr = {
      image = "ghcr.io/hotio/prowlarr";
      environment = {
        TZ = userConfig.global.timezone;
        PUID = "1000";
        PGID = "1000";
      };
      volumes = [
        "/var/lib/prowlarr/config:/config"
      ];
      ports = [ "9696:9696" ];
    };

    radarr = {
      image = "ghcr.io/hotio/radarr";
      environment = {
        TZ = userConfig.global.timezone;
        PUID = "1000";
        PGID = "1000";
      };
      volumes = [
        "/var/lib/radarr/config:/config"
        "/var/lib/media:/data"
      ];
      ports = [ "7878:7878" ];
    };

    sonarr = {
      image = "ghcr.io/hotio/sonarr";
      environment = {
        TZ = userConfig.global.timezone;
        PUID = "1000";
        PGID = "1000";
      };
      volumes = [
        "/var/lib/sonarr/config:/config"
        "/var/lib/media:/data"
      ];
      ports = [ "8989:8989" ];
    };

    jellyseerr = {
      image = "ghcr.io/hotio/jellyseerr";
      environment = {
        TZ = userConfig.global.timezone;
        PUID = "1000";
        PGID = "1000";
      };
      volumes = [
        "/var/lib/jellyseerr/config:/config"
      ];
      ports = [ "5055:5055" ];
    };

    qbittorrent = {
      image = "ghcr.io/hotio/qbittorrent";
      environment = {
        TZ = userConfig.global.timezone;
        PUID = "1000";
        PGID = "1000";
        WEBUI_PORTS = "8080/tcp,8080/udp";
      };
      volumes = [
        "/var/lib/qbittorrent/config:/config"
        "/var/lib/media:/data"
      ];
      ports = [ "8090:8080" ];
    };
  };
}
