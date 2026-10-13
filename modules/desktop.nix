{ pkgs, lib, config, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };
    };
  };

  networking = {
    firewall.enable = false;
    networkmanager.enable = false;
    wireless.iwd.enable = true;
    wireless.iwd.settings = {
      General = {
        AutoEnable = true;
      };
      Settings = {
        AutoConnect = true;
      };
    };
  };

  services = {
    pulseaudio.enable = false;
    pipewire.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
    udev.packages = [ pkgs.brightnessctl ];
    tailscale = {
      enable = true;
      extraSetFlags = [ "--ssh" ];
    };
  };

  security.rtkit.enable = true;

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

  sops.secrets.rc-password.neededForUsers = true;
  sops.secrets.rc-password = { };

  users.users."rc" = {
    isNormalUser = true;
    description = "rc";
    hashedPasswordFile = config.sops.secrets.rc-password.path;
    extraGroups = [
      "networkmanager"
      "video"
      "wheel"
    ];
  };

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };

  programs.ssh.startAgent = true;

  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      bluetui
      rofi-power-menu
      rofi
      nerd-fonts.jetbrains-mono
      swaylock
      iwd
      impala
      brightnessctl
      pwvucontrol
      libnotify
      wdisplays
      wl-clipboard
      mako
      nautilus
    ];
  };

  xdg.mime.defaultApplications = {
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "inode/directory" = "org.gnome.Nautilus.desktop";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = lib.mkDefault [ "gtk" ];
    config.sway.default = lib.mkDefault [ "gtk" ];
  };

}
