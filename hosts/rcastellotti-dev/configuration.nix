{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  grizzlySSHKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILqVLRRlGF1nezM9nM87dUBkp3hKkDB+yqJyqPVwt2Wg";
  polarSSHKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGawr5pI2c6Mbk6c1d9slxH69i7UnoLYIQTAN5KwJ0zx";
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ./services.nix
  ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nix.settings.experimental-features = "nix-command flakes";
  environment.sessionVariables = {
    TERM = "xterm-256color";
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = "${self}/secrets/secrets.yaml";

  networking.hostName = "rcastellotti-dev";
  networking.firewall.enable = true;
  networking.enableIPv6 = true;
  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.firewall.trustedInterfaces = [ "wg0" ];
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking.firewall.allowedTCPPorts = [
    22
    80
    443
  ];
  sops.secrets.wireguard-server = { };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.0.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets.wireguard-server.path;
    peers = [
      {
        publicKey = "R2b+T+B+AfNkN42QTUMuuWa7fHzbTDBucSG7wBKa8VE=";
        allowedIPs = [ "10.0.0.2/32" ];
      }
      {
        publicKey = "tZtYxX29GYLLKfkB+ChJGYmCu51a0bQOpTfRoql0xGE=";
        allowedIPs = [ "10.0.0.3/32" ];
      }
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    grizzlySSHKey
    polarSSHKey
  ];
  system.stateVersion = "26.05";
  programs.fish.enable = true;

  sops.secrets.rcastellotti-dev-password.neededForUsers = true;
  sops.secrets.rcastellotti-dev-password = { };
  users.users.rc = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "rc";
    hashedPasswordFile = config.sops.secrets.rcastellotti-dev-password.path;
    openssh.authorizedKeys.keys = [
      grizzlySSHKey
      polarSSHKey
    ];
    extraGroups = [ "wheel" ];
  };

}
