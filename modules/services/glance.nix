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

  dashboardPage = {
    name = "Dashboard";
    columns = [{
      size = "full";
      widgets = [
        {
          type = "custom-api";
          title = "Bus 31 → Hermetschloo";
          cache = "30s";
          url = "https://transport.opendata.ch/v1/stationboard?station=Waserstrasse&limit=20&transportations[]=bus";
          template = ''
            <ul class="list list-gap-10">
            {{ $count := 0 }}
            {{ range .JSON.Array "stationboard" }}
              {{ if and (lt $count 3) (and (eq (.String "number") "31") (eq (.String "to") "Zürich, Hermetschloo")) }}
                {{ $t := .String "stop.departure" | parseTime "2006-01-02T15:04:05-0700" }}
                <li class="flex justify-between items-center gap-10">
                  <span class="size-h4 color-highlight" {{ $t | toRelativeTime }}></span>
                  <span class="color-paragraph">{{ formatTime "15:04" $t }}{{ if gt (.Int "stop.delay") 0 }} <span class="color-negative">+{{ .Int "stop.delay" }}'</span>{{ end }}</span>
                </li>
                {{ $count = add $count 1 }}
              {{ end }}
            {{ end }}
            </ul>
          '';
        }
        {
          type = "weather";
          location = "Zürich, Switzerland";
          units = "metric";
          hour-format = "24h";
        }
        {
          type = "custom-api";
          title = "Recycling";
          cache = "6h";
          url = "https://openerz.metaodi.ch/api/calendar.json?zip=8053&types=cardboard&types=paper";
          template = ''
            <ul class="list list-gap-10">
            {{ $count := 0 }}
            {{ $today := now | startOfDay }}
            {{ range .JSON.Array "result" }}
              {{ $d := .String "date" | parseTime "DateOnly" }}
              {{ if and (lt $count 5) (not ($d.Before $today)) }}
                <li class="flex justify-between items-center gap-10">
                  <span class="size-h4">{{ if eq (.String "waste_type") "cardboard" }}Karton{{ else }}Papier{{ end }}</span>
                  <span class="color-paragraph" {{ $d | toRelativeTime }}></span>
                </li>
                {{ $count = add $count 1 }}
              {{ end }}
            {{ end }}
            </ul>
          '';
        }
      ];
    }];
  };

  # Generate pages based on what's enabled
  pages = [ dashboardPage ] ++ lib.filter (p: (builtins.length p.columns) > 0) [
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
      pages = pages;
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = userConfig.global.baseDomain;
      extraConfig = ''
        reverse_proxy http://localhost:8080
      '';
    };
  };
}
