{ pkgs, ... }:

let
  site = pkgs.stdenv.mkDerivation {
    pname = "rcast.dev";
    version = "1.0";

    src = ./website;

    nativeBuildInputs = [ pkgs.hugo ];

    buildPhase = "hugo build";

    installPhase = ''
      mkdir -p $out
      cp -r public/* $out/
    '';
  };
in
{
  services.caddy = {
    # acmeCA="https://acme-staging-v02.api.letsencrypt.org/directory";
    enable = true;
    virtualHosts."rcast.dev".extraConfig = ''
      root * ${site}
      file_server
    '';

    globalConfig = ''
      metrics {
        per_host
      }
    '';
    extraConfig = ''
      f.rcast.dev {
        root * /var/www/f
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
