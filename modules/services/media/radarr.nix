{ config, lib, userConfig, ... }:
let
  service = "radarr";
  cfg = config.services.${service};
in
{
  options.services.${service} = {
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.internal.${userConfig.global.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Radarr";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Movie collection manager";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "radarr.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Media";
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service}.dataDir = lib.mkDefault "/var/lib/${service}";

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = userConfig.global.baseDomain;
      extraConfig = ''
        reverse_proxy http://localhost:7878
      '';
    };
  };
}
