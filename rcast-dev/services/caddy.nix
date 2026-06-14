{ pkgs, ... }:

let
  site = pkgs.stdenv.mkDerivation {
    pname = "my-site";
    version = "1.0";

    src = ./website;

    nativeBuildInputs = [ pkgs.bun ];

    buildPhase = ''
      bun install --frozen-lockfile
      bun run main.ts
    '';

    installPhase = ''
      mkdir -p $out
      cp -r dist/* $out/
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
