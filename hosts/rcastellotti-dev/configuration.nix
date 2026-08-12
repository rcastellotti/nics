{
  config,
  lib,
  pkgs,
  self,
  dela,
  ...
}:
let
  rcKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILqVLRRlGF1nezM9nM87dUBkp3hKkDB+yqJyqPVwt2Wg";
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
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
  ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nix.settings.experimental-features = "nix-command flakes";
  environment.sessionVariables = {
    TERM = "xterm-256color";
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = "${self}/secrets/secrets.yaml";

  networking.hostName = "rcastellotti-dev";
  # update firewall rules in main.tf
  networking.firewall.enable = true;
  networking.enableIPv6 = true;
  networking.firewall.allowedUDPPorts = [ 51820 ]; # wireguard
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  sops.secrets.wireguard-server = { };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.0.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets.wireguard-server.path;
    peers = [
      {
        publicKey = "R2b+T+B+AfNkN42QTUMuuWa7fHzbTDBucSG7wBKa8VE=";
        allowedIPs = [ "10.0.0.2/32" ];
      }
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [ rcKey ];
  system.stateVersion = "26.05";
  programs.fish.enable = true;

  sops.secrets.rcastellotti-dev-password.neededForUsers = true;
  sops.secrets.rcastellotti-dev-password = { };
  users.users.rc = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "rc";
    hashedPasswordFile = config.sops.secrets.rcastellotti-dev-password.path;
    openssh.authorizedKeys.keys = [ rcKey ];
    extraGroups = [ "wheel" ];
  };

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
    openssh.enable = true;
    dela = {
      package = dela.packages.${pkgs.system}.default;
      enable = true;
      port = 9076;
    };
    ippy = {
      enable = true;
      port = 9072;
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
      virtualHosts."donts.rcastellotti.dev".extraConfig = ''
        reverse_proxy 127.0.0.1:9077
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
    };
  };
}
