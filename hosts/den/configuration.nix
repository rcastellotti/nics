{
  self,
  config,
  age,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "den";
  networking.wireless.enable = true;
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  environment.systemPackages = with pkgs; [
    vim
    liquidprompt
  ];

  programs.bash.promptInit = ''
    source ${pkgs.liquidprompt}/bin/liquidprompt
  '';

  services.openssh.enable = true;
  services.tailscale.enable = true;

  users.users.rc = {
    isNormalUser = true;
    description = "rc";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ nushell ];
  };

  system.stateVersion = "25.11";

}
