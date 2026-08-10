{ config, lib, ... }:
let
  service = "mosquitto";
  cfg = config.services.${service};
in
{
  config = lib.mkIf cfg.enable {
    # Plaintext passwords: the mosquitto module passes these through systemd
    # credentials and hashes them into its own password file at preStart.
    sops.secrets.mqtt_homeassistant_password = { };
    sops.secrets.mqtt_touchkio_password = { };

    services.${service} = {
      listeners = [
        {
          port = 1883;

          # No address, so 0.0.0.0: the tailnet reaches this for TouchKio on
          # ganymede, and the podman bridge reaches it for the Home Assistant
          # container, which has no route to the tailnet. The firewall below
          # is what keeps it to those two interfaces.
          users = {
            homeassistant = {
              acl = [ "readwrite #" ];
              passwordFile = config.sops.secrets.mqtt_homeassistant_password.path;
            };
            touchkio = {
              acl = [ "readwrite #" ];
              passwordFile = config.sops.secrets.mqtt_touchkio_password.path;
            };
          };
        }
      ];
    };

    # Default-deny, and tailscale0 is not a trusted interface, so 1883 is
    # opened per-interface rather than to the LAN.
    networking.firewall.interfaces = {
      "tailscale0".allowedTCPPorts = [ 1883 ];
      "podman0".allowedTCPPorts = [ 1883 ];
    };
  };
}
