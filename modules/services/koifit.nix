{ config, lib, userConfig, ... }:
let
  service = "koifit";
  cfg = config.services.${service};
in
{
  options.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable Koifit";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/koifit";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.internal.${userConfig.global.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Koifit";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Workout tracker";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "koifit.png";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Fitness";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} 0775 ${userConfig.global.username} users - -"
    ];

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = userConfig.global.baseDomain;
      extraConfig = ''
        reverse_proxy http://localhost:8000
      '';
    };

    virtualisation = {
      podman.enable = true;
      oci-containers.containers.${service} = {
        image = "ghcr.io/vanderpoelliam/koifit:latest";
        autoStart = true;
        extraOptions = [ "--pull=newer" ];
        environment = {
          TZ = userConfig.global.timezone;
          DB_PATH = "/data/db.sqlite";
        };
        volumes = [ "${cfg.configDir}:/data" ];
        ports = [ "127.0.0.1:8000:8000" ];
      };
    };
  };
}
