{ config, lib, pkgs, inputs, userConfig, ... }:
let
  service = "dashboard";
  cfg = config.services.${service};
  tpl = config.sops.templates."dashboard-config.js";

  site = pkgs.runCommand "pi-dashboard" { } ''
    mkdir -p $out
    cp -r ${inputs.pi-dashboard}/{index.html,icons.html,css,js,fonts} $out/
  '';
in
{
  options.services.${service} = {
    enable = lib.mkEnableOption "Wall dashboard";
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.internal.${userConfig.global.baseDomain}";
    };
    homeAssistantUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://ha.internal.${userConfig.global.baseDomain}";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.ha_dashboard_token = { };

    # js/config.js is gitignored, so it is rendered at runtime from
    # sops rather than ever existing in the repo.
    sops.templates."dashboard-config.js" = {
      content = ''
        window.HA_CONFIG = {
          url: '${cfg.homeAssistantUrl}',
          token: '${config.sops.placeholder.ha_dashboard_token}'
        };
      '';
      owner = config.services.caddy.user;
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = userConfig.global.baseDomain;
      extraConfig = ''
        handle /js/config.js {
          root * ${builtins.dirOf tpl.path}
          rewrite * /${builtins.baseNameOf tpl.path}
          file_server
        }
        handle {
          root * ${site}
          file_server
        }
      '';
    };
  };
}
