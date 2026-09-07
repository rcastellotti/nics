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

  networking.hostName = "kodiak";
  networking.firewall.enable = true;
  networking.enableIPv6 = true;
  networking.firewall.allowedTCPPorts = [
    22
    80
    443
  ];
  users.users.root.openssh.authorizedKeys.keys = [
    grizzlySSHKey
    polarSSHKey
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
    openssh.authorizedKeys.keys = [
      grizzlySSHKey
      polarSSHKey
    ];
    extraGroups = [ "wheel" ];
  };

}
