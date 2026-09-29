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
  sops.secrets.icloud-password.owner = "rc";

  imports = [ ./hardware-configuration.nix ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "grizzly";
  networking.firewall.enable = false;
  services.tailscale = {
    enable = true;
  };

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

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
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
    vim
    wl-clipboard
    mako
    rofi
  ];

  programs.steam.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  programs.helium = {
    enable = true;
    policies = {
      "BrowserSignin" = 0;
      "PasswordManagerEnabled" = false;
      "SyncDisabled" = true;
      "DefaultSearchProviderEnabled" = true;
      "ExtensionInstallForcelist" = [
        "oboonakemofpalcgghocfoadofidjkkk"
      ];
    };
  };

  security.polkit.enable = true;
  system.stateVersion = "26.05";

}
