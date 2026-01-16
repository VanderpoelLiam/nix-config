{ config, lib, userConfig, ... }:
let
  service = "jellyfin";
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
      default = "Jellyfin";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "The Free Software Media System";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "jellyfin.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Media";
    };
  };

  config = lib.mkIf cfg.enable {
    # Allow hardware acceleration for Intel GPU transcoding
    systemd.services.jellyfin.serviceConfig = {
      DeviceAllow = [ "/dev/dri" ];
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      extraConfig = ''
        reverse_proxy http://localhost:8096
      '';
    };
  };
}
