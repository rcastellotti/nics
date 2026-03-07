{ ... }:
let
  dnsName = "rcast.dev";
in
{
  services.caddy = {
    enable = true;
    extraConfig = ''
      pad.${dnsName} {
        reverse_proxy 127.0.0.1:9072 {
          header_up X-Forwarded-Proto https
          header_up X-Real-IP {remote_host}
        }
      }
      home.rcast.dev, me.rcast.dev, rcast.dev, home.rcastellotti.dev, me.rcastellotti.dev, rcastellotti.dev {
        root    * /var/www
        file_server
      }
      git.${dnsName} {
        reverse_proxy 127.0.0.1:9073 {
          header_up X-Forwarded-Proto https
          header_up X-Real-IP {remote_host}
        }
      }
      cp.${dnsName} {
        reverse_proxy 127.0.0.1:9074 {
          header_up Host {upstream_hostport}
          header_up X-Forwarded-Proto {scheme}
          header_up Upgrade {http.request.header.Upgrade}
          header_up Connection {http.request.header.Connection}
        }
      }
    '';
  };
}
