{
  config,
  pkgs,
  self,
  ...
}:
{
  nix.settings.experimental-features = "nix-command flakes";

  sops.defaultSopsFile = "${self}/secrets/secrets.yaml";
  sops.age.sshKeyPaths = [ "/tmp/grizzly-ssh-key" ];

  imports = [
    ./hardware-configuration.nix
    ../../services/syncthing.nix
    ../../modules/desktop.nix
  ];

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
      hash = "sha256-7GoH8YLCoPmPExQxoga2FHB58zQDoZVf1BBwkVi0SsQ=";
    };
    virtualHosts."https://local.rcastellotti.dev".extraConfig = ''
      reverse_proxy localhost:9172
      tls {
        dns cloudflare {file.${config.sops.secrets.cloudflare-api-token.path}}
        }
    '';
  };

  environment.systemPackages = with pkgs; [
    fish
    vim
    wl-clipboard
    mako
    android-studio
    jadx
    jetbrains.idea
    openjdk17
  ];

  programs.steam.enable = true;

  system.stateVersion = "26.05";
}
