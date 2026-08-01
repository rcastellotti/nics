{
  config,
  pkgs,
  self,
  lib,
  ...
}:

{
  nix.settings.experimental-features = "nix-command flakes";

  age.secrets = {
    wireguard-client = {
      file = "${self}/secrets/wireguard-client.age";
    };

    cloudflare-api-token = {
      file = "${self}/secrets/CLOUDFLARE_API_TOKEN.age";
      owner = "caddy";
      group = "caddy";
      mode = "0400";
    };
  };
  age.identityPaths = [
    "/tmp/rc-ssh-key"
  ];
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "den";
  networking.firewall.enable = false;
  networking.hosts = {
    "10.0.0.1" = [ "rcastellotti-dev" ];
  };
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.0.0.2/32" ];
      listenPort = 51820;
      privateKeyFile = config.age.secrets.wireguard-client.path;
      peers = [
        {
          publicKey = "gZeKUDU/F7xcX6X26AjKz3EJcHKa8wcqsrNOysULnzw=";
          allowedIPs = [ "10.0.0.1/32" ];
          endpoint = "wg.rcastellotti.dev:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
  networking.networkmanager.wifi.powersave = false;
  time.timeZone = "Europe/Rome";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.openssh = {
    enable = true;
  };
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.2.4"
      ];
      hash = "sha256-7GoH8YLCoPmPExQxoga2FHB58zQDoZVf1BBwkVi0SsQ=";
    };
    virtualHosts."http://:9179".extraConfig = ''
      root * /srv
      file_server browse
    '';
    virtualHosts."https://local.rcastellotti.dev".extraConfig = ''
      reverse_proxy localhost:5173
      tls {
        dns cloudflare {file.${config.age.secrets.cloudflare-api-token.path}}
        }
    '';
  };

  users.users."rc" = {
    isNormalUser = true;
    description = "rc";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  environment.systemPackages = with pkgs; [
    fish
    gnome-tweaks
    vim
  ];

  system.stateVersion = "26.05";
}
