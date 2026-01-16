{ config, lib, userConfig, ... }:
let
  service = "pihole";
  cfg = config.services.${service};
in
{
  options.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable Pi-hole";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/pihole";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.internal.${userConfig.global.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Pi-hole";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "DNS and ad-blocking";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "pi-hole.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Network";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} 0755 root root - -"
      "d ${cfg.configDir}/pihole 0755 root root - -"
      "d ${cfg.configDir}/dnsmasq.d 0755 root root - -"
    ];

    services.caddy.virtualHosts."${cfg.url}" = {
      extraConfig = ''
        redir / /admin
        reverse_proxy http://localhost:8081
      '';
    };

    virtualisation = {
      podman.enable = true;
      oci-containers.containers.${service} = {
        image = "pihole/pihole:latest";
        autoStart = true;
        extraOptions = [
          "--pull=newer"
          "--cap-add=CAP_SYS_TIME"
          "--cap-add=CAP_SYS_NICE"
        ];
        ports = [
          "53:53/tcp"
          "53:53/udp"
          "127.0.0.1:8081:80/tcp"
        ];
        environment = {
          TZ = userConfig.global.timezone;
          FTLCONF_dns_listeningMode = "all";
          FTLCONF_webserver_api_password_FILE = "/run/secrets/pihole_password";
        };
        volumes = [
          "${cfg.configDir}/pihole:/etc/pihole"
          "${cfg.configDir}/dnsmasq.d:/etc/dnsmasq.d"
          "${config.sops.secrets.pihole_password.path}:/run/secrets/pihole_password:ro"
        ];
      };
    };
  };
}
