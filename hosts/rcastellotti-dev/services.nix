{
  config,
  lib,
  pkgs,
  dela,
  tma,
  ...
}:
let
  delaPackage = dela.packages.${pkgs.stdenv.hostPlatform.system}.default;
  website = pkgs.callPackage ../../services/rcastellotti-dev/package.nix { };
in
{
  system.activationScripts.fixWebDirPerms = ''
    mkdir -p /var/www/f
    chown -R rc:users /var/www/f
    chmod -R 777 /var/www/f
  '';

  sops.secrets.forgejo-password.owner = config.services.forgejo.user;
  systemd.services.forgejo.preStart = lib.mkAfter ''
    adminCmd="${lib.getExe config.services.forgejo.package} admin user"
    password="$(cat ${config.sops.secrets.forgejo-password.path})"
    $adminCmd create \
      --admin --email 'me@rcastellotti.dev' \
      --username 'rc' --password "$password" \
      --must-change-password=false || true
  '';

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
    tma = {
      enable = true;
      package = tma.packages.${pkgs.stdenv.hostPlatform.system}.default;
      port = 9075;
    };
    dela = {
      package = delaPackage;
      enable = true;
      port = 9076;
    };
    forgejo = {
      enable = true;
      package = pkgs.forgejo;
      database.type = "sqlite3";
      settings = {
        server = {
          DOMAIN = "g.rcastellotti.dev";
          ROOT_URL = "https://g.rcastellotti.dev/";
          HTTP_PORT = 9073;
          PROTOCOL = "http";
          HTTP_ADDR = "127.0.0.1";
          SSH_PORT = lib.head config.services.openssh.ports;
        };
        repository.ENABLE_PUSH_CREATE_USER = true;
        service.DISABLE_REGISTRATION = true;
      };
    };
    caddy = {
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
  };
}
