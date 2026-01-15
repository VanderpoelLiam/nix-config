{ userConfig, ... }:
{
  virtualisation.oci-containers.containers.homeassistant = {
    image = "ghcr.io/home-assistant/home-assistant:stable";
    extraOptions = [
      "--network=host"
      "--privileged"
      "--device=/dev/ttyACM0:/dev/ttyACM0"
    ];
    environment.TZ = userConfig.global.timezone;
    volumes = [
      "/var/lib/homeassistant:/config"
      "/etc/localtime:/etc/localtime:ro"
      "/run/dbus:/run/dbus:ro"
    ];
  };
}
