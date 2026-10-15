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
  networking.firewall.allowedUDPPorts = [ 44821 ];
  networking.firewall.trustedInterfaces = [ "wg0" ];

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 44821;
    privateKeyFile = config.sops.secrets."wireguard-kodiak-private-key".path;
    peers = [
      {
        publicKey = "CikbbsOo7gykEygcCCFTv/qIXfdnS+LDBOdzYC4S9n8="; # ll
        allowedIPs = [ "10.100.0.2/32" ];
      }
    ];
  };

  networking.nat = {
    enable = true;
    externalInterface = "enp1s0";
    internalInterfaces = [ "wg0" ];
  };

  system.stateVersion = "26.05";
  programs.fish.enable = true;

  sops.secrets.kodiak-password.neededForUsers = true;
  sops.secrets.kodiak-password = { };
  sops.secrets."wireguard-kodiak-private-key" = {
    mode = "0400";
  };
  users.users.rc = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "rc";
    hashedPasswordFile = config.sops.secrets.kodiak-password.path;
    extraGroups = [ "wheel" ];
  };

}
