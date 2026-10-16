{
  config,
  pkgs,
  self,
  ...
}:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  sops.defaultSopsFile = "${self}/secrets/secrets.yaml";
  sops.age.sshKeyPaths = [ "/tmp/polar-ssh-key" ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-backup";
  home-manager.users.rc = {
    imports = [
      ../../home/desktop.nix
    ];
  };

  networking.hostName = "polar";

  imports = [
    ./hardware-configuration.nix
    ../../services/syncthing.nix
    ../../modules/bocs.nix
    ../../modules/desktop.nix
  ];

  system.stateVersion = "26.05";
}
