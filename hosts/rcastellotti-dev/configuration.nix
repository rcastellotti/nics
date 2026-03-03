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
  ];

  networking.hostName = "rcastellotti-dev";
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  environment.systemPackages = [ pkgs.tailscale ];
  services.openssh = {
    enable = true;
  };
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  users.users.rc = {
    isNormalUser = true;
    description = "rc";
    initialHashedPassword = "$y$j9T$17wh/3yJrjKDieCQllkEM0$tPKMhABvPxNGJkcvzMI26pqhxRVKs3TtTMD2pHBN0b3";
    extraGroups = [
      "wheel"
    ];
    packages = with pkgs; [
      nushell
      tailscale
    ];
  };

  age.secrets.tailscale-authkey = {
    file = "${self}/hosts/rcastellotti-dev/secrets/tailscale-authkey.age";
  };

  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale-authkey.path; # clean!
    # optional extras
    openFirewall = true; # opens the UDP port
    # interfaceName = "userspace-networking"; # or "tailscale0", etc.
    extraUpFlags = [
      "--ssh"
      "--accept-routes"
    ];
  };
  system.stateVersion = "25.11";
}
