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

  imports = [
    ./hardware-configuration.nix
    ../../services/syncthing.nix
    ../../modules/desktop.nix
  ];

  networking.hostName = "polar";

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  environment.systemPackages = with pkgs; [
    fish
    vim
    wl-clipboard
    mako
  ];

  programs.steam.enable = true;

  system.stateVersion = "26.05";
}
