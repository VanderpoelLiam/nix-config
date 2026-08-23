{ config, lib, ... }:
let
  # Native nixpkgs services that need to share the media group. qBittorrent is
  # absent on purpose: it runs as a container and declares its own user.
  mediaServices = [ "sonarr" "radarr" "jellyfin" ];
  anyEnabled =
    config.services.torrent.enable
    || lib.any (s: config.services.${s}.enable) mediaServices;
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

  # Guarded so hosts that run no media services get no /data tree.
  config = lib.mkIf anyEnabled {
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
  };
}
