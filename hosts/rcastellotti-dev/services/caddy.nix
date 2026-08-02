{ pkgs, dela, ... }:

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
  delaPackage = dela.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  services.caddy = {
    # acmeCA="https://acme-staging-v02.api.letsencrypt.org/directory";
    enable = true;
    virtualHosts."rcastellotti.dev".extraConfig = ''
      root * ${site}
      file_server
    '';
    virtualHosts."g.rcastellotti.dev".extraConfig = ''
      reverse_proxy 127.0.0.1:9073 {
        header_up X-Forwarded-Proto https
        header_up X-Real-IP {remote_host}
      }
    '';
    virtualHosts."f.rcastellotti.dev".extraConfig = ''
      root * /var/www/f
      file_server browse
    '';
    virtualHosts."i.rcastellotti.dev".extraConfig = ''
      reverse_proxy 127.0.0.1:9072
    '';
    virtualHosts."tma.rcastellotti.dev".extraConfig = ''
      reverse_proxy 127.0.0.1:9075
    '';
    virtualHosts."dela.rcastellotti.dev".extraConfig = ''
      @api path /api/* /openapi*

      handle @api {
        reverse_proxy localhost:9076
      }

      handle {
        root * ${delaPackage}/www
        try_files {path} /index.html
        file_server
      }
    '';
    virtualHosts."dev.dela.rcastellotti.dev".extraConfig = ''
      @api path /api/* /openapi*

      handle @api {
        reverse_proxy localhost:9077
      }

      handle {
        root * /var/www/dela/dist/www
        try_files {path} /index.html
        file_server
      }
    '';
    globalConfig = ''
      metrics {
        per_host
      }
    '';
  };
}
