{ config, ... }:
{
  sops.secrets = {
    cloudflare_api_token = {
      sopsFile = ../../../../secrets/hyperion.yaml;
    };
    pihole_password = {
      sopsFile = ../../../../secrets/hyperion.yaml;
    };
  };

  # Create environment file for ACME/Cloudflare with proper format
  sops.templates."cloudflare-dns.env".content = ''
    CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder.cloudflare_api_token}
  '';
}
