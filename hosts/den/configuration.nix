{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "den";
  networking.wireless.enable = true;
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Brussels";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.rc = {
    isNormalUser = true;
    description = "rc";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      nushell
    ];
  };

  programs.firefox.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
  ];

  services.openssh.enable = true;
  networking.firewall.enable = false;

  system.stateVersion = "25.11";

}
