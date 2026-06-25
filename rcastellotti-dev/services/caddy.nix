{ pkgs, ... }:

let
  site = pkgs.stdenv.mkDerivation {
    pname = "rcastellotti.dev";
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
    virtualHosts."rcastellotti.dev".extraConfig = ''
      root * ${site}
      file_server
    '';
    virtualHosts."i.rcastellotti.dev".extraConfig = ''
      reverse_proxy 127.0.0.1:9072
    '';
    globalConfig = ''
      metrics {
        per_host
      }
    '';
    extraConfig = ''
      f.rcastellotti.dev {
        root * /var/www/f
        file_server browse
      }
      g.rcastellotti.dev {
        reverse_proxy 127.0.0.1:9073 {
          header_up X-Forwarded-Proto https
          header_up X-Real-IP {remote_host}
        }
      }
    '';
  };
}
