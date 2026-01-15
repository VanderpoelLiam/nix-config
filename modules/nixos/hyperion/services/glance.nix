{ userConfig, ... }:
{
  virtualisation.oci-containers.containers.glance = {
    image = "glanceapp/glance:latest";
    environment.TZ = userConfig.global.timezone;
    volumes = [
      "/var/lib/glance/glance.yml:/app/glance.yml"
    ];
    ports = [ "8082:8080" ];
  };
}
