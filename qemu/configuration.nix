{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./hardware-configuration.nix];

  boot.loader.systemd-boot.enable = true;

  networking.hostName = "rcastellotti-dev";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };
  services.caddy = {
    enable = true;
    package = pkgs.caddy;
    configFile = pkgs.writeText "Caddyfile" (builtins.readFile ./Caddyfile);
  };
  services.tailscale.enable = true;

  users.users.rc = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMDKMBfTzBW+55YEE/ctTJQClc0tcwG+yjCWV0TI4+wd rc@bearbook"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    jq
    jless
    vim
    git
    curl
    fish

    tailscale
    caddy
  ];

  system.stateVersion = "26.05";
}
