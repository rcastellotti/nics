{
  config,
  lib,
  pkgs,
  modulesPath,
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
  system.stateVersion = "25.11";
}
