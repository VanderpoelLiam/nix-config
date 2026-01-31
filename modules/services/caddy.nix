{ config, lib, userConfig, ... }:
let
  cfg = config.services.caddy;
in
{
  config = lib.mkIf cfg.enable {
    # Declare the Cloudflare API token secret
    sops.secrets.cloudflare_api_token = {};

    # Create environment file with proper format for ACME
    sops.templates."cloudflare-dns.env".content = ''
      CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder.cloudflare_api_token}
    '';

    # Configure ACME for wildcard certificate using Cloudflare DNS-01 challenge
    security.acme = {
      acceptTerms = true;
      defaults.email = "acme@localhost";

      certs."${userConfig.global.baseDomain}" = {
        group = config.services.caddy.group;
        domain = "*.internal.${userConfig.global.baseDomain}";
        extraDomainNames = [ "internal.${userConfig.global.baseDomain}" ];
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        dnsPropagationCheck = true;
        environmentFile = config.sops.templates."cloudflare-dns.env".path;
      };
    };

    # Open firewall ports for HTTP/HTTPS
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    networking.firewall.allowedUDPPorts = [ 443 ]; # For HTTP/3
  };
}
