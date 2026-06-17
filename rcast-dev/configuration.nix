{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  rcKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILqVLRRlGF1nezM9nM87dUBkp3hKkDB+yqJyqPVwt2Wg";
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ./services/caddy.nix
    ./services/forgejo.nix
  ];

  services.ippy.enable = true;
  services.ippy.port = 9072;

  networking.hostName = "rcast-dev";
  # update firewall rules in main.tf
  networking.firewall.enable = true;
  networking.firewall.allowedUDPPorts = [ 51820 ]; # wireguard
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  nix.settings.experimental-features = "nix-command flakes";

  environment.sessionVariables = {
    TERM = "xterm-256color";
  };

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [ rcKey ];

  system.stateVersion = "26.05";

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets.rcast-dev-password.file = "${self}/secrets/rcast-dev-password.age";

  users.users.rc = {
    isNormalUser = true;
    description = "rc";
    hashedPasswordFile = config.age.secrets.rcast-dev-password.path;
    openssh.authorizedKeys.keys = [ rcKey ];
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      yazi
      git
      htop
      fastfetch
      vim
      fish
      ncdu
    ];
  };

  age.secrets.wireguard-server.file = "${self}/secrets/wireguard-server.age";
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.0.0.1/24" ];
    listenPort = 51820;

    privateKeyFile = config.age.secrets.wireguard-server.path;

    peers = [
      {
        publicKey = "R2b+T+B+AfNkN42QTUMuuWa7fHzbTDBucSG7wBKa8VE=";
        allowedIPs = [ "10.0.0.2/32" ];
      }
    ];
  };

}
