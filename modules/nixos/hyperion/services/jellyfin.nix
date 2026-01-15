{ ... }:
{
  services.jellyfin.enable = true;

  systemd.services.jellyfin.serviceConfig = {
    DeviceAllow = [ "/dev/dri" ];
  };
}
