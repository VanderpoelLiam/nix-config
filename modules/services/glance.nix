{ config, lib, userConfig, ... }:
let
  service = "glance";
  cfg = config.services.${service};

  # Helper to create a bookmark widget for a service
  makeServiceLink = serviceName: let
    svcCfg = config.services.${serviceName};
  in lib.optionalAttrs (svcCfg.enable or false) {
    title = svcCfg.homepage.name;
    url = "https://${svcCfg.url}";
    icon = "<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/${svcCfg.homepage.icon}' width=32 height=32>";
  };

  # Group services by category
  mediaServices = lib.filter (x: x != {}) [
    (makeServiceLink "jellyfin")
    (makeServiceLink "sonarr")
    (makeServiceLink "radarr")
    (makeServiceLink "prowlarr")
    (makeServiceLink "jellyseerr")
    (makeServiceLink "qbittorrent")
  ];

  automationServices = lib.filter (x: x != {}) [
    (makeServiceLink "homeassistant")
  ];

  networkServices = lib.filter (x: x != {}) [
    (makeServiceLink "pihole")
  ];

  fitnessServices = lib.filter (x: x != {}) [
    (makeServiceLink "koifit")
  ];

  # Generate pages based on what's enabled
  pages = lib.filter (p: (builtins.length p.columns) > 0) [
    (lib.optionalAttrs (mediaServices != []) {
      name = "Media";
      columns = [{
        size = "full";
        widgets = [{
          type = "bookmarks";
          groups = [{
            links = mediaServices;
          }];
        }];
      }];
    })
    (lib.optionalAttrs (automationServices != []) {
      name = "Automation";
      columns = [{
        size = "full";
        widgets = [{
          type = "bookmarks";
          groups = [{
            links = automationServices;
          }];
        }];
      }];
    })
    (lib.optionalAttrs (networkServices != []) {
      name = "Network";
      columns = [{
        size = "full";
        widgets = [{
          type = "bookmarks";
          groups = [{
            links = networkServices;
          }];
        }];
      }];
    })
    (lib.optionalAttrs (fitnessServices != []) {
      name = "Fitness";
      columns = [{
        size = "full";
        widgets = [{
          type = "bookmarks";
          groups = [{
            links = fitnessServices;
          }];
        }];
      }];
    })
  ];
in
{
  options.services.${service} = {
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.internal.${userConfig.global.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Glance";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Dashboard";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "glance.png";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Dashboard";
    };
  };

  config = lib.mkIf cfg.enable {
    # Auto-generate dashboard from enabled services
    services.glance.settings = {
      server = {
        host = "localhost";
        port = 8080;
      };
      pages = if pages != [] then pages else [{
        name = "Home";
        columns = [{
          size = "full";
          widgets = [{ type = "calendar"; }];
        }];
      }];
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      extraConfig = ''
        reverse_proxy http://localhost:8080
      '';
    };
  };
}
