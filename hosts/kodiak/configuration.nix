{
  config,
  lib,
  pkgs,
  self,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ./services.nix
    ../../services/syncthing.nix
    ../../modules/bocs.nix
    ../../modules/ssh-keys.nix
  ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  systemd.services.ballast = {
    description = "Reserve fallback disk space that can be deleted when the disk fills up";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if [ ! -e /home/rc/ballast ]; then
        ${pkgs.util-linux}/bin/fallocate -l 5G /home/rc/ballast || true
        ${pkgs.coreutils}/bin/chown rc:users /home/rc/ballast
      fi
    '';
  };

  environment.sessionVariables = {
    TERM = "xterm-256color";
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = "${self}/secrets/secrets.yaml";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.rc = import ../../home/core.nix;

  networking.hostName = "kodiak";
  networking.firewall.enable = true;
  networking.enableIPv6 = true;
  networking.firewall.allowedTCPPorts = [
    22
    80
    443
  ];
  system.stateVersion = "26.05";
  programs.fish.enable = true;

  sops.secrets.kodiak-password.neededForUsers = true;
  sops.secrets.kodiak-password = { };
  users.users.rc = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "rc";
    hashedPasswordFile = config.sops.secrets.kodiak-password.path;
    extraGroups = [ "wheel" ];
  };

}
