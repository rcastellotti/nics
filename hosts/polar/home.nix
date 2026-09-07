{ pkgs, ... }:

{
  imports = [ ../../home/common.nix ];

  home.packages = [ pkgs.tailscale ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings.kodiak = {
      HostName = "kodiak.t.rcastellotti.dev";
      User = "rc";
    };
    settings.grizzly = {
      HostName = "10.0.0.2";
      User = "rc";
    };
  };
}
