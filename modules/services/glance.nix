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

  sbbDeparturesWidget = {
    type = "custom-api";
    title = "Bus 31 → Hermetschloo";
    cache = "30s";
    url = "https://transport.opendata.ch/v1/stationboard?station=Waserstrasse&limit=20&transportations[]=bus";
    template = ''
      {{ $cutoff := offsetNow "2m" }}
      {{ $count := 0 }}
      <ul class="list list-gap-10">
      {{ range .JSON.Array "stationboard" }}
        {{ $t := .String "stop.departure" | parseTime "2006-01-02T15:04:05-0700" }}
        {{ if and (lt $count 3) (and ($t.After $cutoff) (and (eq (.String "number") "31") (eq (.String "to") "Zürich, Hermetschloo"))) }}
          <li class="flex justify-between items-center gap-10">
            <span class="size-h4 color-highlight" {{ $t | toRelativeTime }}></span>
            <span class="color-paragraph">{{ formatTime "15:04" $t }}{{ if gt (.Int "stop.delay") 0 }} <span class="color-negative">+{{ .Int "stop.delay" }}'</span>{{ end }}</span>
          </li>
          {{ $count = add $count 1 }}
        {{ end }}
      {{ end }}
      </ul>
    '';
  };

  weatherWidget = {
    type = "html";
    source = ''
      <img src="/assets/weather.png" alt="Weather forecast" style="width:100%;display:block;border-radius:6px">
      <p style="font-size:0.7em;opacity:0.55;margin:4px 0 0;text-align:right">
        Data: <a href="https://www.meteoschweiz.admin.ch" target="_blank" rel="noopener">MeteoSwiss</a>
        · Render: <a href="https://github.com/caco3/MeteoSwiss-Forecast" target="_blank" rel="noopener">caco3/MeteoSwiss-Forecast</a>
      </p>
    '';
  };

  recyclingWidget = {
    type = "custom-api";
    title = "Recycling";
    cache = "6h";
    url = "https://openerz.metaodi.ch/api/calendar.json?zip=8053&types=cardboard&types=paper";
    template = ''
      {{ $tomorrow := offsetNow "24h" | formatTime "DateOnly" }}
      {{ $karton := "" }}
      {{ $papier := "" }}
      {{ range .JSON.Array "result" }}
        {{ $date := .String "date" }}
        {{ if eq $date $tomorrow }}
          {{ if and (eq (.String "waste_type") "cardboard") (eq $karton "") }}{{ $karton = $date }}{{ end }}
          {{ if and (eq (.String "waste_type") "paper") (eq $papier "") }}{{ $papier = $date }}{{ end }}
        {{ end }}
      {{ end }}
      {{ if or (ne $karton "") (ne $papier "") }}
        <ul class="list list-gap-10">
          {{ if ne $karton "" }}{{ $kt := $karton | parseTime "DateOnly" }}
            <li class="flex justify-between items-center gap-10">
              <span class="size-h4">Karton</span>
              <span class="color-paragraph">tomorrow · {{ formatTime "Mon Jan 02" $kt }}</span>
            </li>
          {{ end }}
          {{ if ne $papier "" }}{{ $pt := $papier | parseTime "DateOnly" }}
            <li class="flex justify-between items-center gap-10">
              <span class="size-h4">Papier</span>
              <span class="color-paragraph">tomorrow · {{ formatTime "Mon Jan 02" $pt }}</span>
            </li>
          {{ end }}
        </ul>
      {{ else }}
        <p class="color-paragraph">Nothing tomorrow.</p>
      {{ end }}
    '';
  };

  dashboardPage = {
    name = "Dashboard";
    columns = [{
      size = "full";
      widgets = [
        sbbDeparturesWidget
        weatherWidget
        recyclingWidget
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
        assets-path = config.services.meteoswiss-forecast.dataDir;
      };
      document.head = ''<meta http-equiv="refresh" content="60">'';
      branding.hide-footer = true;
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
