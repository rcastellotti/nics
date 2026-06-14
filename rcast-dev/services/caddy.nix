{ ... }:
{
  services.caddy = {
    # acmeCA="https://acme-staging-v02.api.letsencrypt.org/directory";
    enable = true;
    globalConfig = ''
      metrics {
        per_host
      }
    '';
    extraConfig = ''
       rcast.dev {
        root    * /var/www/website
        file_server
      }
      f.rcast.dev {
        root * /var/www/files
        file_server browse
      }
      g.rcast.dev {
        reverse_proxy 127.0.0.1:9073 {
          header_up X-Forwarded-Proto https
          header_up X-Real-IP {remote_host}
        }
      }
    '';
  };
}
