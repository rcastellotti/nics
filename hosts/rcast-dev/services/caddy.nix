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
      home.rcast.dev, me.rcast.dev, rcast.dev, home.rcastellotti.dev {
        root    * /var/www
        file_server
      }
    '';
  };
}
