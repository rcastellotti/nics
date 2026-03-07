{
  config,
  lib,
  pkgs,
  modulesPath,
  self,
  age,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ./services/caddy.nix
    ./services/hedgedoc.nix
    ./services/forgejo.nix
  ];

  networking.hostName = "rcast-dev";
  networking.useDHCP = lib.mkDefault true;
  networking.firewall.enable = false;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  nix.settings.experimental-features = "nix-command flakes";

  environment.systemPackages = [ pkgs.tailscale ];
  services.openssh.enable = true;
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  users.users.rc = {
    isNormalUser = true;
    description = "rc";
    initialHashedPassword = "$y$j9T$17wh/3yJrjKDieCQllkEM0$tPKMhABvPxNGJkcvzMI26pqhxRVKs3TtTMD2pHBN0b3";
    extraGroups = [
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB0MSXuAS2WEbtoZa9mFAC2EFSePpfN1X3dfV6YchCFiAAAABHNzaDo= ssh:" # content of authorized_keys file
    ];
    packages = with pkgs; [
      nushell
      tailscale
      yazi
      git
      htop
      fastfetch
      vim
    ];
  };

  age.secrets.tailscale-authkey.file = "${self}/hosts/rcast-dev/secrets/tailscale-authkey.age";

  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale-authkey.path;
    openFirewall = true;
    extraUpFlags = [
      "--ssh"
      "--accept-routes"
    ];
  };
  system.stateVersion = "25.11";
}
