{ config, lib, userConfig, ... }:
let
  # Native nixpkgs services that need to share the media group. qBittorrent is
  # absent on purpose: it runs as a container and declares its own user.
  mediaServices = [ "sonarr" "radarr" "jellyfin" ];
  anyEnabled =
    config.services.torrent.enable
    || lib.any (s: config.services.${s}.enable) mediaServices;

  # Where the media stack runs. Change this if it moves.
  mediaHost = "trantor";

  webServices = [ "sonarr" "radarr" "prowlarr" "seerr" "jellyfin" "torrent" ];
  elsewhere = lib.filter (s: !config.services.${s}.enable) webServices;
in
{
  imports = [
    ./sonarr.nix
    ./radarr.nix
    ./prowlarr.nix
    ./seerr.nix
    ./jellyfin.nix
    ./torrent.nix
  ];

  config = lib.mkMerge [

  # Guarded so hosts that run no media services get no /data tree.
  (lib.mkIf anyEnabled {
    # Static gid: torrent.nix needs it at eval time to pass PGID to the container.
    users.groups.media.gid = 340;

    users.users = builtins.listToAttrs (
      map (service: {
        name = service;
        value.extraGroups = [ "media" ];
      }) (lib.filter (s: config.services.${s}.enable) mediaServices)
    );

    systemd.tmpfiles.rules = [
      "d /data                0775 root media - -"
      "d /data/torrents       0775 root media - -"
      "d /data/torrents/movies 0775 root media - -"
      "d /data/torrents/tv    0775 root media - -"
      "d /data/media          0775 root media - -"
      "d /data/media/movies   0775 root media - -"
      "d /data/media/tv       0775 root media - -"
    ];
  })

  # Serve the vhosts for services this host does not run.
  {
    services.caddy.virtualHosts = builtins.listToAttrs (
      map (service: {
        name = config.services.${service}.url;
        value = {
          useACMEHost = userConfig.global.baseDomain;
          # By tailnet name: these vhost names resolve back to this host.
          extraConfig = ''
            reverse_proxy https://${mediaHost} {
              header_up Host {host}
              transport http {
                tls_server_name {host}
              }
            }
          '';
        };
      }) elsewhere
    );
  }

  ];
}
