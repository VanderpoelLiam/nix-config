{ ... }:
let
  mediaServices = [ "sonarr" "radarr" "qbittorrent" "jellyfin" ];
in
{
  imports = [
    ./sonarr.nix
    ./radarr.nix
    ./prowlarr.nix
    ./jellyseerr.nix
    ./jellyfin.nix
    ./qbittorrent.nix
  ];
  users.groups.media = { };

  users.users = builtins.listToAttrs (map (service: {
    name = service;
    value.extraGroups = [ "media" ];
  }) mediaServices);

  systemd.tmpfiles.rules = [
    "d /data                0775 root media - -"
    "d /data/torrents       0775 root media - -"
    "d /data/torrents/movies 0775 root media - -"
    "d /data/torrents/tv    0775 root media - -"
    "d /data/media          0775 root media - -"
    "d /data/media/movies   0775 root media - -"
    "d /data/media/tv       0775 root media - -"
  ];
}
