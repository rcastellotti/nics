{
  config,
  pkgs,
  self,
  ...
}:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  sops.defaultSopsFile = "${self}/secrets/secrets.yaml";
  sops.age.sshKeyPaths = [ "/tmp/grizzly-ssh-key" ];

  imports = [
    ./hardware-configuration.nix
    ../../services/syncthing.nix
    ../../modules/desktop.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-backup";
  home-manager.users.rc = {
    imports = [
      ../../home/desktop.nix
    ];
  };

  networking.hostName = "grizzly";

  sops.secrets.cloudflare-api-token = {
    key = "CLOUDFLARE_API_TOKEN";
    owner = "caddy";
    group = "caddy";
    mode = "0400";
  };
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.2.4"
      ];
      hash = "sha256-xRJ5evsAJ2akg47j3Bt6YDXJOgX88B/rKNP50KSVyNY=";
    };
    virtualHosts."https://local.rcastellotti.dev".extraConfig = ''
      reverse_proxy localhost:9172
      tls {
        dns cloudflare {file.${config.sops.secrets.cloudflare-api-token.path}}
        }
    '';
  };

  programs.steam.enable = true;

  system.stateVersion = "26.05";
}
