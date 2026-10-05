{
  config,
  pkgs,
  self,
  ...
}:

{
  nix.settings.experimental-features = "nix-command flakes";

  sops.defaultSopsFile = "${self}/secrets/secrets.yaml";
  sops.age.sshKeyPaths = [ "/tmp/polar-ssh-key" ];
  sops.secrets.icloud-password.owner = "rc";

  imports = [
    ./hardware-configuration.nix
    ../../services/syncthing.nix
    ../../modules/desktop.nix
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "polar";
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

  system.stateVersion = "26.05";
}
