{ config, lib, userConfig, ... }:
let
  service = "seafile";
  cfg = config.services.${service};

  # Pi-hole binds 0.0.0.0:53, so aardvark-dns cannot claim a bridge gateway and
  # container DNS is unavailable on this host. The stack therefore runs on its
  # own bridge with fixed addresses, and Seafile is pointed at those directly
  # instead of at the "db" and "redis" names upstream's compose file uses.
  network = service;
  dbIp = "10.90.0.10";
  redisIp = "10.90.0.11";
in
{
  options.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable Seafile";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/seafile";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8082;
    };
    adminEmail = lib.mkOption {
      type = lib.types.str;
      default = userConfig.global.gitEmail;
      description = "Admin account created on first startup only.";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.internal.${userConfig.global.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Seafile";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "File sync and share";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "seafile.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Storage";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      seafile_db_root_password = { };
      seafile_db_password = { };
      seafile_redis_password = { };
      seafile_jwt_private_key = { };
      seafile_admin_password = { };
    };

    sops.templates."seafile-db.env".content = ''
      MYSQL_ROOT_PASSWORD=${config.sops.placeholder.seafile_db_root_password}
    '';

    sops.templates."seafile-redis.env".content = ''
      REDIS_PASSWORD=${config.sops.placeholder.seafile_redis_password}
    '';

    sops.templates."seafile.env".content = ''
      INIT_SEAFILE_MYSQL_ROOT_PASSWORD=${config.sops.placeholder.seafile_db_root_password}
      SEAFILE_MYSQL_DB_PASSWORD=${config.sops.placeholder.seafile_db_password}
      REDIS_PASSWORD=${config.sops.placeholder.seafile_redis_password}
      JWT_PRIVATE_KEY=${config.sops.placeholder.seafile_jwt_private_key}
      INIT_SEAFILE_ADMIN_PASSWORD=${config.sops.placeholder.seafile_admin_password}
    '';

    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} 0750 root root - -"
      "d ${cfg.configDir}/data 0750 root root - -"
      # Ownership is left alone: mariadb's entrypoint chowns the data directory
      # to its own uid on every start.
      "d ${cfg.configDir}/db - - - - -"
    ];

    # podman refuses a network config without an id, and derives it as the
    # sha256 of the network name.
    environment.etc."containers/networks/${network}.json".text = builtins.toJSON {
      name = network;
      id = builtins.hashString "sha256" network;
      driver = "bridge";
      network_interface = "${network}0";
      dns_enabled = false;
      internal = false;
      ipv6_enabled = false;
      ipam_options.driver = "host-local";
      subnets = [
        {
          subnet = "10.90.0.0/24";
          gateway = "10.90.0.1";
        }
      ];
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = userConfig.global.baseDomain;
      extraConfig = ''
        reverse_proxy http://localhost:${toString cfg.port}
      '';
    };

    virtualisation = {
      podman.enable = true;

      oci-containers.containers = {
        seafile-db = {
          image = "docker.io/library/mariadb:10.11";
          autoStart = true;
          networks = [ network ];
          extraOptions = [
            "--pull=newer"
            "--ip=${dbIp}"
          ];
          environment = {
            MYSQL_LOG_CONSOLE = "true";
            MARIADB_AUTO_UPGRADE = "1";
          };
          environmentFiles = [ config.sops.templates."seafile-db.env".path ];
          volumes = [ "${cfg.configDir}/db:/var/lib/mysql" ];
        };

        seafile-redis = {
          image = "docker.io/library/redis:8-alpine";
          autoStart = true;
          networks = [ network ];
          extraOptions = [
            "--pull=newer"
            "--ip=${redisIp}"
          ];
          environmentFiles = [ config.sops.templates."seafile-redis.env".path ];
          # Cache only, so persistence is off and no volume is needed.
          cmd = [
            "sh"
            "-c"
            ''exec redis-server --requirepass "$REDIS_PASSWORD" --save "" --appendonly no''
          ];
        };

        seafile = {
          image = "docker.io/seafileltd/seafile-mc:13.0-latest";
          autoStart = true;
          dependsOn = [ "seafile-db" "seafile-redis" ];
          networks = [ network ];
          extraOptions = [ "--pull=newer" ];
          environment = {
            TIME_ZONE = userConfig.global.timezone;

            SEAFILE_MYSQL_DB_HOST = dbIp;
            SEAFILE_MYSQL_DB_PORT = "3306";
            SEAFILE_MYSQL_DB_USER = "seafile";
            SEAFILE_MYSQL_DB_CCNET_DB_NAME = "ccnet_db";
            SEAFILE_MYSQL_DB_SEAFILE_DB_NAME = "seafile_db";
            SEAFILE_MYSQL_DB_SEAHUB_DB_NAME = "seahub_db";

            CACHE_PROVIDER = "redis";
            REDIS_HOST = redisIp;
            REDIS_PORT = "6379";

            # Baked into the config files in /shared on first startup; changing
            # either afterwards means editing them by hand.
            SEAFILE_SERVER_HOSTNAME = cfg.url;
            SEAFILE_SERVER_PROTOCOL = "https";
            INIT_SEAFILE_ADMIN_EMAIL = cfg.adminEmail;

            SITE_ROOT = "/";
            NON_ROOT = "false";
            SEAFILE_LOG_TO_STDOUT = "false";
            ENABLE_GO_FILESERVER = "true";
            # Both need their own container and extra Caddy routes.
            ENABLE_SEADOC = "false";
            ENABLE_NOTIFICATION_SERVER = "false";
          };
          environmentFiles = [ config.sops.templates."seafile.env".path ];
          volumes = [ "${cfg.configDir}/data:/shared" ];
          ports = [ "127.0.0.1:${toString cfg.port}:80" ];
        };
      };
    };
  };
}
