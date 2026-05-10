{ config, lib, pkgs, ... }:
let
  service = "meteoswiss-forecast";
  cfg = config.services.${service};

  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    matplotlib numpy requests urllib3 pytz pillow
  ]);

  src = pkgs.fetchFromGitHub {
    owner = "caco3";
    repo = "MeteoSwiss-Forecast";
    rev = "9d6307f3d98564ce0308a6887f9a812785f55f99";
    sha256 = "0ynw12s027bij6ycp18m44waxaqjsrm4hgii6liphsxlnwy3a51r";
  };

  patched = pkgs.runCommand "meteoswiss-forecast-src" {} ''
    cp -r ${src} $out
    chmod -R u+w $out
    substituteInPlace $out/meteoswissForecast.py \
      --replace 'os.path.dirname(os.path.realpath(__file__)) + "/symbols/"' '"${cfg.dataDir}/symbols/"' \
      --replace "rainAxis.plot([timestampLocal], [rainScaleMax* 0.97], 'v', color='green', markersize=10)" "pass"
  '';
in
{
  options.services.${service} = {
    enable = lib.mkEnableOption "MeteoSwiss weather forecast PNG generator";
    zip = lib.mkOption {
      type = lib.types.int;
      description = "Swiss postal code for the forecast location.";
    };
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/meteoswiss-forecast";
    };
    interval = lib.mkOption {
      type = lib.types.str;
      default = "30min";
      description = "How often to regenerate the forecast (systemd OnUnitActiveSec).";
    };
    width = lib.mkOption {
      type = lib.types.int;
      default = 800;
    };
    daysToShow = lib.mkOption {
      type = lib.types.int;
      default = 1;
    };
    locale = lib.mkOption {
      type = lib.types.str;
      default = "de_CH.utf8";
    };
    darkMode = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    i18n.extraLocales = [ "${cfg.locale}/UTF-8" ];

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}        0755 root root - -"
      "d ${cfg.dataDir}/symbols 0755 root root - -"
    ];

    systemd.services.meteoswiss-forecast = {
      description = "Generate MeteoSwiss weather forecast PNG";
      path = [ pythonEnv pkgs.curl pkgs.imagemagick ];
      serviceConfig = {
        Type = "oneshot";
      };
      preStart = ''
        if [ -z "$(ls -A ${cfg.dataDir}/symbols 2>/dev/null)" ]; then
          echo "Fetching MeteoSwiss weather symbols (one-time)..."
          tmp=$(mktemp -d)
          base="https://www.meteoschweiz.admin.ch/static/resources/weather-symbols"
          for i in $(seq 1 50) $(seq 101 150); do
            curl -sSf "$base/$i.svg" -o "$tmp/$i.svg" || true
          done
          for f in "$tmp"/*.svg; do
            [ -e "$f" ] || continue
            convert -background transparent -resize 256x256 -density 500 \
              "$f" "${cfg.dataDir}/symbols/$(basename "$f" .svg).png"
          done
          rm -rf "$tmp"
        fi
      '';
      script = ''
        ${pythonEnv}/bin/python3 ${patched}/meteoswissForecast.py \
          -z ${toString cfg.zip} \
          -f ${cfg.dataDir}/weather.png \
          -m ${cfg.dataDir}/weather.json \
          --width ${toString cfg.width} \
          --days-to-show ${toString cfg.daysToShow} \
          --locale ${cfg.locale} \
          ${lib.optionalString cfg.darkMode "--dark-mode"}
      '';
    };

    systemd.timers.meteoswiss-forecast = {
      description = "Periodically regenerate MeteoSwiss forecast";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = cfg.interval;
        Unit = "meteoswiss-forecast.service";
      };
    };
  };
}
