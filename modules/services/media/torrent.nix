{ config, lib, pkgs, userConfig, ... }:
let
  service = "torrent";
  cfg = config.services.${service};
  port = toString cfg.webuiPort;

  # libtorrent enumerates its listen interfaces once, at startup. When gluetun
  # reconnects -- a healthcheck failure is enough -- tun0 goes away and comes
  # back, and qBittorrent never re-binds to it. Every peer socket is then
  # sourced from eth0, where gluetun's OUTPUT policy silently drops it, so
  # torrents sit at zero peers until the container is restarted. Naming the
  # interface makes libtorrent re-bind on its own, and keeps it off eth0.
  pinToTunnel = pkgs.writeShellScript "qbittorrent-pin-tunnel" ''
    conf=${cfg.configDir}/config/qBittorrent.conf
    [ -f "$conf" ] || exit 0
    tmp=$(${pkgs.coreutils}/bin/mktemp)
    ${pkgs.gawk}/bin/awk '
      /^Session\\Interface=/ { next }
      /^Session\\InterfaceName=/ { next }
      { print }
      /^\[BitTorrent\]$/ && !seen {
        print "Session\\Interface=tun0"
        print "Session\\InterfaceName=tun0"
        seen = 1
      }
      END {
        if (!seen) {
          print "[BitTorrent]"
          print "Session\\Interface=tun0"
          print "Session\\InterfaceName=tun0"
        }
      }
    ' "$conf" > "$tmp"
    ${pkgs.coreutils}/bin/chown --reference="$conf" "$tmp"
    ${pkgs.coreutils}/bin/chmod --reference="$conf" "$tmp"
    ${pkgs.coreutils}/bin/mv "$tmp" "$conf"
  '';
in
{
  options.services.${service} = {
    enable = lib.mkEnableOption "qBittorrent, tunnelled through Mullvad via gluetun";
    webuiPort = lib.mkOption {
      type = lib.types.port;
      default = 8090;
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/qBittorrent";
    };
    serverCities = lib.mkOption {
      type = lib.types.str;
      default = "Zurich";
      description = "Mullvad exit cities, comma separated. Pick P2P-friendly ones.";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "qbittorrent.internal.${userConfig.global.baseDomain}";
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
    sops.secrets.mullvad_wg_private_key = { };
    sops.secrets.mullvad_wg_addresses = { };

    sops.templates."gluetun.env".content = ''
      WIREGUARD_PRIVATE_KEY=${config.sops.placeholder.mullvad_wg_private_key}
      WIREGUARD_ADDRESSES=${config.sops.placeholder.mullvad_wg_addresses}
    '';

    # Below 400, where NixOS does not auto-allocate, since PUID/PGID are needed at eval time.
    users.users.qbittorrent = {
      isSystemUser = true;
      group = "qbittorrent";
      uid = 341;
      extraGroups = [ "media" ];
    };
    users.groups.qbittorrent.gid = 341;

    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} 0750 qbittorrent media - -"
    ];

    virtualisation = {
      podman.enable = true;

      oci-containers.containers = {
        gluetun = {
          image = "docker.io/qmcgaw/gluetun:latest";
          autoStart = true;
          extraOptions = [
            "--cap-add=NET_ADMIN"
            "--device=/dev/net/tun:/dev/net/tun"
            "--pull=newer"
          ];
          environment = {
            VPN_SERVICE_PROVIDER = "mullvad";
            VPN_TYPE = "wireguard";
            SERVER_CITIES = cfg.serverCities;
            FIREWALL_OUTBOUND_SUBNETS = "10.88.0.0/16";
            TZ = userConfig.global.timezone;
          };
          environmentFiles = [ config.sops.templates."gluetun.env".path ];
          ports = [ "127.0.0.1:${port}:${port}" ];
        };

        qbittorrent = {
          image = "ghcr.io/hotio/qbittorrent:latest";
          autoStart = true;
          dependsOn = [ "gluetun" ];
          extraOptions = [
            "--network=container:gluetun"
            "--pull=newer"
          ];
          environment = {
            PUID = toString config.users.users.qbittorrent.uid;
            PGID = toString config.users.groups.media.gid;
            WEBUI_PORTS = "${port}/tcp,${port}/udp";
            TZ = userConfig.global.timezone;
          };
          volumes = [
            "${cfg.configDir}:/config"
            "/data:/data"
          ];
        };
      };
    };

    # dependsOn is only After+Requires; these keep qbittorrent in step with gluetun's netns.
    systemd.services.podman-qbittorrent = {
      bindsTo = [ "podman-gluetun.service" ];
      upheldBy = [ "podman-gluetun.service" ];
      serviceConfig = {
        Restart = lib.mkForce "always";
        # Runs while the container is down, so qBittorrent cannot overwrite it on exit.
        ExecStartPre = lib.mkAfter [ "${pinToTunnel}" ];
      };
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = userConfig.global.baseDomain;
      extraConfig = ''
        reverse_proxy http://localhost:${port}
      '';
    };
  };
}
