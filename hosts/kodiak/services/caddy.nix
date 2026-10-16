{
  config,
  pkgs,
  dela,
  ...
}:
let
  delaPackage = dela.packages.${pkgs.stdenv.hostPlatform.system}.default;
  website = pkgs.callPackage ../../../services/rcastellotti-dev/package.nix { };
in
{
  system.activationScripts.fixWebDirPerms = ''
    mkdir -p /var/www/f
    chown -R rc:users /var/www/f
    chmod -R 777 /var/www/f
  '';

  sops.secrets.cloudflare-api-token = {
    key = "CLOUDFLARE_API_TOKEN";
    owner = "caddy";
    group = "caddy";
    mode = "0400";
  };

  services.caddy = {
    # acmeCA="https://acme-staging-v02.api.letsencrypt.org/directory";
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.2.4"
      ];
      hash = "sha256-xRJ5evsAJ2akg47j3Bt6YDXJOgX88B/rKNP50KSVyNY=";
    };
    virtualHosts."rcastellotti.dev".extraConfig = ''
      root * ${website}
      file_server
    '';
    virtualHosts."g.rcastellotti.dev".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString config.services.forgejo.settings.server.HTTP_PORT} {
        header_up X-Forwarded-Proto https
        header_up X-Real-IP {remote_host}
      }
    '';
    virtualHosts."f.rcastellotti.dev".extraConfig = ''
      root * /var/www/f
      file_server browse
    '';
    virtualHosts."tma.rcastellotti.dev".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString config.services.tma.port}
    '';
    virtualHosts."https://m.kodiak.t.rcastellotti.dev".extraConfig = ''
      @outsideTailnet not remote_ip 100.64.0.0/10 fd7a:115c:a1e0::/48
      abort @outsideTailnet
      reverse_proxy 127.0.0.1:${toString config.services.navidrome.settings.Port}
      tls {
        dns cloudflare {file.${config.sops.secrets.cloudflare-api-token.path}}
        # Bypass Headscale's split DNS, which cannot answer the SOA queries Caddy uses for ACME zone discovery.
        resolvers 1.1.1.1 1.0.0.1
      }
    '';
    virtualHosts."vpn.rcastellotti.dev".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString config.services.headscale.port}
    '';
    virtualHosts."dela.rcastellotti.dev".extraConfig = ''
      @api path /api/* /openapi*
      handle @api {
        reverse_proxy localhost:${toString config.services.dela.port}
      }
      handle {
        root * ${delaPackage}/www
        try_files {path} /index.html
        file_server
      }
    '';
  };
}
