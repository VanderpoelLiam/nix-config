{ config, lib, userConfig, ... }:
let
  service = "qbittorrent";
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
      default = "qBittorrent";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Torrent client";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "qbittorrent.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Media";
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service}.webuiPort = lib.mkDefault 8080;

    services.caddy.virtualHosts."${cfg.url}" = {
      extraConfig = ''
        reverse_proxy http://localhost:8080
      '';
    };
  };
}
