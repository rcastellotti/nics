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
  navidromePort = 4533;
  website = pkgs.callPackage ../../services/rcastellotti-dev/package.nix { };
  headscalePolicy = pkgs.writeText "headscale-policy.json" (builtins.toJSON {
    ssh = [
      {
        action = "accept";
        src = [ "autogroup:member" ];
        dst = [ "autogroup:self" ];
        users = [ "autogroup:nonroot" ];
      }
    ];
  });
in
{
  system.activationScripts.fixWebDirPerms = ''
    mkdir -p /var/www/f
    chown -R rc:users /var/www/f
    chmod -R 777 /var/www/f
  '';

  sops.secrets.forgejo-password.owner = config.services.forgejo.user;
  sops.secrets.cloudflare-api-token = {
    key = "CLOUDFLARE_API_TOKEN";
    owner = "caddy";
    group = "caddy";
    mode = "0400";
  };
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
    tailscale = {
      enable = true;
      openFirewall = true;
      extraSetFlags = [ "--ssh" ];
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
    headscale = {
      enable = true;
      address = "127.0.0.1";
      port = 9077;
      settings = {
        server_url = "https://vpn.rcastellotti.dev";
        policy = {
          mode = "file";
          path = headscalePolicy;
        };
        dns = {
          magic_dns = true;
          base_domain = "t.rcastellotti.dev";
          extra_records = [
            {
              name = "m.kodiak.t.rcastellotti.dev";
              type = "A";
              value = "100.64.0.2";
            }
          ];
          nameservers.global = [
            "1.1.1.1"
            "1.0.0.1"
          ];
        };
      };
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
    navidrome = {
      enable = true;
      openFirewall = false;
      settings = {
        Address = "127.0.0.1";
        Port = navidromePort;
        MusicFolder = "/var/lib/navidrome/music";
      };
    };
    caddy = {
      # acmeCA="https://acme-staging-v02.api.letsencrypt.org/directory";
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/cloudflare@v0.2.4"
        ];
        hash = "sha256-7GoH8YLCoPmPExQxoga2FHB58zQDoZVf1BBwkVi0SsQ=";
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
  };
}
