{ pkgs, userConfig, ... }:
{
  virtualisation.oci-containers.containers.koifit = {
    image = "ghcr.io/vanderpoelliam/koifit:latest";
    environment = {
      TZ = userConfig.global.timezone;
      DB_PATH = "/data/db.sqlite";
    };
    volumes = [
      "/var/lib/koifit:/data"
    ];
    ports = [ "8000:8000" ];
  };
}
