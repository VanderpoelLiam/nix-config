{ config, lib, userConfig, ... }:
let
  service = "homeassistant";
  cfg = config.services.${service};
in
{
  options.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable Home Assistant";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/homeassistant";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "ha.internal.${userConfig.global.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Home Assistant";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Home automation platform";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "home-assistant.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Automation";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} 0775 ${userConfig.global.username} users - -"
    ];

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = userConfig.global.baseDomain;
      extraConfig = ''
        reverse_proxy http://localhost:8123
      '';
    };

    virtualisation = {
      podman.enable = true;
      oci-containers.containers.${service} = {
        image = "ghcr.io/home-assistant/home-assistant:stable";
        autoStart = true;
        # Host networking so Home Assistant can discover devices on the LAN.
        extraOptions = [
          "--pull=newer"
          "--privileged"
          "--network=host"
          "--device=/dev/ttyACM0:/dev/ttyACM0"
        ];
        volumes = [
          "${cfg.configDir}:/config"
          "/etc/zoneinfo:/etc/localtime:ro"
          "/run/dbus:/run/dbus:ro"
        ];
        environment = {
          TZ = userConfig.global.timezone;
        };
      };
    };
  };
}
