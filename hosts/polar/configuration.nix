{ ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config = {
    allowBroken = true;
    allowUnfree = true;
  };

  networking = {
    computerName = "polar";
    hostName = "polar";
    localHostName = "polar";
  };

  system = {
    primaryUser = "rc";
    stateVersion = 6;
  };

  users.users.rc.home = "/Users/rc";

  # Determinate manages the Nix daemon and build users.
  nix.enable = false;
}
