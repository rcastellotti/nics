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

  services.caddy = {
    # acmeCA="https://acme-staging-v02.api.letsencrypt.org/directory";
    enable = true;
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
